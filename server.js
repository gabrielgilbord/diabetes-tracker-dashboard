const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const crypto = require('crypto');
const algorithm = 'aes-256-cbc';
const secretKey = process.env.ENCRYPTION_SECRET_KEY;
const jwt = require('jsonwebtoken');

// Configuración JWT
const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-this-in-production';
const JWT_EXPIRES_IN = '30d'; // 30 días

// Logs globales para errores no capturados
process.on('uncaughtException', function (err) {
  console.error('Excepción no capturada:', err);
});
process.on('unhandledRejection', function (reason, promise) {
  console.error('Rechazo no manejado:', reason);
});

const app = express();

// Middleware para permitir solicitudes CORS
app.use(cors());

// Middleware para analizar el cuerpo de las solicitudes
app.use(bodyParser.json());

// Cliente de Supabase
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

// Middleware de autenticación JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Token de acceso requerido' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      console.log('❌ Token inválido:', err.message);
      return res.status(403).json({ error: 'Token inválido o expirado' });
    }
    req.user = user;
    next();
  });
};

// Ruta básica de prueba
app.get('/', (req, res) => {
  res.send('¡Servidor funcionando correctamente!');
});

// Endpoint para registrar un usuario con contraseña cifrada
app.post('/register', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Cifrar la contraseña
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Revisar el UserID mayor actual
    const { data: maxIdData, error: maxIdError } = await supabase
      .from('users')
      .select('UserID')
      .order('UserID', { ascending: false })
      .limit(1);
    if (maxIdError) throw maxIdError;
    let nextUserId = 1;
    if (maxIdData && maxIdData.length > 0 && maxIdData[0].UserID) {
      nextUserId = maxIdData[0].UserID + 1;
    }

    // Insertar usuario con UserID explícito
    const { data, error } = await supabase
      .from('users')
      .insert([{ UserID: nextUserId, Username: username, PasswordHash: passwordHash }]);
    if (error) throw error;

    res.status(201).send('Usuario registrado correctamente');
  } catch (error) {
    console.error('❌ Error al registrar el usuario:', error);
    res.status(500).send('Error al registrar el usuario');
  }
});

app.post('/login', async (req, res) => {
  try {
    const { username, password, UUID } = req.body;
    // Buscar usuario por username
    const { data: users, error } = await supabase
      .from('users')
      .select('UserID, PasswordHash, UUID')
      .eq('Username', username)
      .limit(1);
    if (error) throw error;
    if (!users || users.length === 0) {
      return res.status(400).send('Usuario no encontrado');
    }
    const user = users[0];
    const passwordMatch = await bcrypt.compare(password, user.PasswordHash);
    if (!passwordMatch) {
      return res.status(400).send('Contraseña incorrecta');
    }
    // Si UUID almacenado es null o vacío, actualizamos con el enviado
    if (!user.UUID) {
      const { error: updateError } = await supabase
        .from('users')
        .update({ UUID: UUID })
        .eq('UserID', user.UserID);
      if (updateError) throw updateError;
    }
    // Si UUID existe, lo comparamos
    if (user.UUID && user.UUID !== UUID) {
      return res.status(400).send('Dispositivo no reconocido');
    }
    
    // Generar token JWT
    const token = jwt.sign(
      { 
        userId: user.UserID, 
        username: username,
        uuid: UUID 
      }, 
      JWT_SECRET, 
      { expiresIn: JWT_EXPIRES_IN }
    );
    
    res.status(200).json({ 
      success: true, 
      message: 'Autenticación exitosa',
      token: token 
    });
  } catch (error) {
    console.error('❌ Error en login:', error);
    res.status(500).send('Error al intentar autenticar');
  }
});

// Helper para saber si la tabla tiene columna 'iv' (simulado, ya que Supabase no lo permite dinámicamente)
function supportsIV(table) {
  // Lista de tablas que tienen columna 'iv'
  return ['insulindata', 'fooddata', 'exercisedata', 'mooddata', 'periodrecords'].includes(table);
}

// Helper para cifrar o marcar como texto plano (sin cifrar fechas)
function encryptOrMark(text, table, fieldName = '') {
  if (!text) return text;
  // No cifrar fechas
  const fechaFields = [
    'date_time', 'dateTime', 'startDate', 'endDate', 'actualDateTime',
    'exercise_start_time', 'exercise_end_time', 'exerciseStartTime', 'exerciseEndTime'
  ];
  if (fechaFields.includes(fieldName)) {
    return { encryptedData: text, iv: null };
  }
  if (supportsIV(table)) {
    const enc = encrypt(text);
    return { encryptedData: enc.encryptedData, iv: enc.iv };
  } else {
    return { encryptedData: '__PLAIN__' + text, iv: null };
  }
}

// Helper para descifrar o devolver texto plano
function decryptOrPlain(text, iv) {
  if (!text) return text;
  if (typeof text !== 'string') return text;
  if (text.startsWith('__PLAIN__')) return text.replace('__PLAIN__', '');
  if (!iv) return text; // Si no hay IV, asume texto plano
  try {
    return decrypt(text, iv);
  } catch (e) {
    return text; // Si falla el descifrado, devuelve el texto original
  }
}

// Utilidad para convertir fechas a ISO solo si son válidas
function toIsoOrNull(val) {
  if (!val) return null;
  const d = new Date(val);
  return isNaN(d.getTime()) ? null : d.toISOString();
}

// Utilidad para convertir fechas a formato SQL 'YYYY-MM-DD HH:mm:ss' si es necesario
function formatDateToSQL(val) {
  if (!val) return null;
  // Si ya es formato ISO o YYYY-MM-DD HH:mm:ss, lo devolvemos tal cual
  if (/\d{4}-\d{2}-\d{2}/.test(val)) return val;
  // Si es DD/MM/YYYY HH:mm, lo convertimos
  const match = val.match(/(\d{2})\/(\d{2})\/(\d{4})[ T](\d{2}):(\d{2})/);
  if (match) {
    const [ , dd, mm, yyyy, hh, min ] = match;
    return `${yyyy}-${mm}-${dd} ${hh}:${min}:00`;
  }
  // Si no, intentamos parsear con Date
  const d = new Date(val);
  if (!isNaN(d.getTime())) {
    return d.toISOString().replace('T', ' ').substring(0, 19);
  }
  return null;
}

// INSULIN
app.post('/insulinForm', authenticateToken, async (req, res) => {
  try {
    const { username, insulinType, dose, date_time, actualDateTime } = req.body;
    const table = 'insulindata';
    const encInsulinType = encryptOrMark(insulinType, table, 'insulinType');
    const encDose = encryptOrMark(dose.toString(), table, 'dose');
    // Fechas sin cifrar
    const plainDateTime = date_time;
    const plainActualDateTime = actualDateTime;
    const { data, error } = await supabase
      .from(table)
      .insert([{
        username,
        insulinType: encInsulinType.encryptedData,
        insulintype_iv: encInsulinType.iv,
        dose: encDose.encryptedData,
        dose_iv: encDose.iv,
        date_time: plainDateTime,
        actualDateTime: plainActualDateTime
      }]);
    if (error) throw error;
    res.status(200).send('Insulina registrada correctamente');
  } catch (error) {
    console.error('❌ Error al guardar insulina:', error);
    res.status(500).send('Error al guardar los datos en la base de datos');
  }
});

// INSULIN - Actualizar
app.put('/updateInsulinRecord', authenticateToken, async (req, res) => {
  try {
    const { id, insulinType, dose, date_time, actualDateTime } = req.body;
    const table = 'insulindata';
    const safeInsulinType = insulinType ?? '';
    const safeDose = dose ?? '';
    // Formatear fechas igual que en el POST
    const plainDateTime = formatDateToSQL(date_time);
    const plainActualDateTime = formatDateToSQL(actualDateTime);
    const encInsulinType = encryptOrMark(safeInsulinType, table, 'insulinType');
    const encDose = encryptOrMark(safeDose.toString(), table, 'dose');
    const { error } = await supabase
      .from(table)
      .update({
        insulinType: encInsulinType.encryptedData,
        insulintype_iv: encInsulinType.iv,
        dose: encDose.encryptedData,
        dose_iv: encDose.iv,
        date_time: plainDateTime,
        actualDateTime: plainActualDateTime
      })
      .eq('id', id);
    if (error) throw error;
    res.status(200).send('Registro de insulina actualizado correctamente');
  } catch (error) {
    console.error('❌ Error al actualizar insulina:', error);
    res.status(500).send('Error al actualizar el registro de insulina');
  }
});

// FOOD
app.post('/foodForm', authenticateToken, async (req, res) => {
  try {
    const { username, foodType, quantity, carbs, dateTime } = req.body;
    const table = 'fooddata';
    const encFoodType = encryptOrMark(foodType, table, 'foodType');
    const encQuantity = encryptOrMark(quantity.toString(), table, 'quantity');
    const encCarbs = encryptOrMark(carbs.toString(), table, 'carbs');
    // Fecha sin cifrar
    const plainDateTime = dateTime;
    const { data, error } = await supabase
      .from(table)
      .insert([{
        username,
        food_type: encFoodType.encryptedData,
        food_type_iv: encFoodType.iv,
        quantity: encQuantity.encryptedData,
        quantity_iv: encQuantity.iv,
        carbs: encCarbs.encryptedData,
        carbs_iv: encCarbs.iv,
        date_time: plainDateTime
      }]);
    if (error) throw error;
    res.status(200).send('Comida registrada correctamente');
  } catch (error) {
    console.error('❌ Error al guardar los datos en la base de datos:', error);
    res.status(500).send('Error al guardar los datos en la base de datos');
  }
});

// FOOD - Actualizar
app.put('/updateFoodRecord', authenticateToken, async (req, res) => {
  try {
    const { id, foodType, quantity, carbs, date_time } = req.body;
    const table = 'fooddata';
    const safeFoodType = foodType ?? '';
    const safeQuantity = quantity ?? '';
    const safeCarbs = carbs ?? '';
    // Formatear fecha igual que en el POST
    const plainDateTime = formatDateToSQL(date_time);
    const encFoodType = encryptOrMark(safeFoodType, table, 'foodType');
    const encQuantity = encryptOrMark(safeQuantity.toString(), table, 'quantity');
    const encCarbs = encryptOrMark(safeCarbs.toString(), table, 'carbs');
    const { error } = await supabase
      .from(table)
      .update({
        food_type: encFoodType.encryptedData,
        food_type_iv: encFoodType.iv,
        quantity: encQuantity.encryptedData,
        quantity_iv: encQuantity.iv,
        carbs: encCarbs.encryptedData,
        carbs_iv: encCarbs.iv,
        date_time: plainDateTime
      })
      .eq('id', id);
    if (error) throw error;
    res.status(200).send('Registro de comida actualizado correctamente');
  } catch (error) {
    console.error('❌ Error al actualizar comida:', error);
    res.status(500).send('Error al actualizar el registro de comida');
  }
});

// EXERCISE
app.post('/exerciseForm', authenticateToken, async (req, res) => {
  try {
    const { username, exerciseType, intensity, startTime, endTime, description, dateTime } = req.body;
    const table = 'exercisedata';
    const encExerciseType = encryptOrMark(exerciseType, table, 'exerciseType');
    const encDescription = encryptOrMark(description, table, 'description');
    // Fechas sin cifrar
    const plainStartTime = startTime;
    const plainEndTime = endTime;
    const plainDateTime = dateTime;
    const { data, error } = await supabase
      .from(table)
      .insert([{
        username,
        exercise_type: encExerciseType.encryptedData,
        exercise_type_iv: encExerciseType.iv,
        intensity,
        exercise_start_time: plainStartTime,
        exercise_end_time: plainEndTime,
        exercise_description: encDescription.encryptedData,
        exercise_description_iv: encDescription.iv,
        date_time: plainDateTime
      }]);
    if (error) throw error;
    res.status(200).send('Ejercicio registrado correctamente');
  } catch (error) {
    console.error('❌ Error al guardar los datos en la base de datos:', error);
    res.status(500).send('Error al guardar los datos en la base de datos');
  }
});

// EXERCISE - Actualizar
app.put('/updateExerciseRecord', authenticateToken, async (req, res) => {
  try {
    console.log('Datos recibidos en updateExerciseRecord:', req.body);
    const { id, exerciseType, intensity, exerciseStartTime, exerciseEndTime, exerciseDescription, date_time } = req.body;
    const table = 'exercisedata';
    const safeExerciseType = exerciseType ?? '';
    const safeDescription = exerciseDescription ?? '';
    // Formatear fechas igual que en el POST
    const plainStartTime = formatDateToSQL(exerciseStartTime);
    const plainEndTime = formatDateToSQL(exerciseEndTime);
    const plainDateTime = formatDateToSQL(date_time);
    if (!plainStartTime) {
      console.log('Falta hora de inicio en la actualización de ejercicio');
      return res.status(400).send('El campo hora de inicio es obligatorio.');
    }
    if (!plainEndTime) {
      console.log('Falta hora de fin en la actualización de ejercicio');
      return res.status(400).send('El campo hora de fin es obligatorio.');
    }
    const encExerciseType = encryptOrMark(safeExerciseType, table, 'exerciseType');
    const encDescription = encryptOrMark(safeDescription, table, 'description');
    const { error } = await supabase
      .from(table)
      .update({
        exercise_type: encExerciseType.encryptedData,
        exercise_type_iv: encExerciseType.iv,
        intensity,
        exercise_start_time: plainStartTime,
        exercise_end_time: plainEndTime,
        exercise_description: encDescription.encryptedData,
        exercise_description_iv: encDescription.iv,
        date_time: plainDateTime
      })
      .eq('id', id);
    if (error) throw error;
    res.status(200).send('Registro de ejercicio actualizado correctamente');
  } catch (error) {
    console.error('❌ Error al actualizar ejercicio:', error);
    res.status(500).send('Error al actualizar el registro de ejercicio');
  }
});

// MOOD
app.post('/moodForm', async (req, res) => {
  try {
    const { username, mood_value, out_of_routine, routine_description, emotions, other_emotion, date_time } = req.body;
    const table = 'mooddata';
    // Asegurar valores por defecto para campos opcionales
    const safeRoutineDescription = routine_description ?? '';
    const safeOtherEmotion = other_emotion ?? '';
    let safeEmotions = emotions;
    if (!Array.isArray(safeEmotions)) {
      if (typeof safeEmotions === 'string') {
        try {
          safeEmotions = JSON.parse(safeEmotions);
        } catch (e) {
          safeEmotions = safeEmotions.split(',').map(e => e.trim()).filter(e => e !== '');
        }
      } else if (safeEmotions == null) {
        safeEmotions = [];
      } else {
        safeEmotions = [safeEmotions];
      }
    }
    // Filtrar nulos y vacíos
    safeEmotions = safeEmotions.filter(e => typeof e === 'string' && e.trim() !== '');
    const encRoutineDescription = encryptOrMark(safeRoutineDescription, table, 'routine_description');
    const encOtherEmotion = encryptOrMark(safeOtherEmotion, table, 'other_emotion');
    const encEmotions = safeEmotions.map(e => encryptOrMark(e, table, 'emotions'));
    // Fecha sin cifrar
    const plainDateTime = date_time;
    const { data, error } = await supabase
      .from(table)
      .insert([{
        username,
        mood_value,
        out_of_routine,
        routine_description: encRoutineDescription.encryptedData,
        routine_description_iv: encRoutineDescription.iv,
        emotions: encEmotions.map(e => e.encryptedData),
        emotions_iv: encEmotions.map(e => e.iv),
        other_emotion: encOtherEmotion.encryptedData,
        other_emotion_iv: encOtherEmotion.iv,
        date_time: plainDateTime
      }]);
    if (error) throw error;
    res.status(200).send('Estado de ánimo registrado correctamente');
  } catch (error) {
    console.error('❌ Error al guardar el estado de ánimo:', error);
    res.status(500).send('Error al guardar el estado de ánimo');
  }
});

// PERIOD
app.post('/addPeriodRecord', authenticateToken, async (req, res) => {
  let { username, startDate, endDate, intensity, symptoms, notes } = req.body;
  const table = 'periodrecords';
  try {
    // Log de depuración para ver el body completo
    console.log('Body recibido:', req.body);
    // Asegurar que symptoms es un array real
    if (typeof symptoms === 'string') {
      try {
        symptoms = JSON.parse(symptoms);
      } catch (e) {
        // Si no es JSON, intentar separar por comas
        symptoms = symptoms.split(',').map(s => s.trim()).filter(s => s !== '');
      }
    }
    if (!Array.isArray(symptoms)) symptoms = [];
    // Filtrar nulos, undefined y vacíos
    symptoms = symptoms.filter(s => typeof s === 'string' && s.trim() !== '');
    console.log('Síntomas recibidos:', symptoms);
    const encIntensity = encryptOrMark(intensity, table, 'intensity');
    const encSymptoms = symptoms.map(s => encryptOrMark(s, table, 'symptoms'));
    const encNotes = encryptOrMark(notes, table, 'notes');
    // Fechas sin cifrar
    const plainStartDate = startDate;
    const plainEndDate = endDate;
    const { error } = await supabase
      .from(table)
      .insert([{ 
        username, 
        startDate: plainStartDate, 
        endDate: plainEndDate, 
        intensity: encIntensity.encryptedData, 
        intensity_iv: encIntensity.iv,
        symptoms: encSymptoms.map(s => s.encryptedData),
        symptoms_iv: encSymptoms.map(s => s.iv),
        notes: encNotes.encryptedData,
        notes_iv: encNotes.iv
      }]);
    if (error) throw error;
    res.status(200).json({ message: 'Registro de período añadido correctamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al añadir el registro de período' });
  }
});

// 2. Actualizar registro de período
app.put('/updatePeriodRecord', authenticateToken, async (req, res) => {
  let { id, startDate, endDate, intensity, symptoms, notes } = req.body;
  const table = 'periodrecords';
  try {
    // Procesar symptoms igual que en el POST
    if (typeof symptoms === 'string') {
      try {
        symptoms = JSON.parse(symptoms);
      } catch (e) {
        symptoms = symptoms.split(',').map(s => s.trim()).filter(s => s !== '');
      }
    }
    if (!Array.isArray(symptoms)) symptoms = [];
    symptoms = symptoms.filter(s => typeof s === 'string' && s.trim() !== '');
    const encIntensity = encryptOrMark(intensity, table, 'intensity');
    const encSymptoms = symptoms.map(s => encryptOrMark(s, table, 'symptoms'));
    const encNotes = encryptOrMark(notes, table, 'notes');
    const { error } = await supabase
      .from('periodrecords')
      .update({
        startDate: startDate,
        endDate: endDate,
        intensity: encIntensity.encryptedData,
        intensity_iv: encIntensity.iv,
        symptoms: encSymptoms.map(s => s.encryptedData),
        symptoms_iv: encSymptoms.map(s => s.iv),
        notes: encNotes.encryptedData,
        notes_iv: encNotes.iv
      })
      .eq('id', id);
    if (error) throw error;
    res.status(200).json({ message: 'Registro de período actualizado correctamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar el registro de período' });
  }
});

// 4. Endpoint para actualizar sexo y bomba_insulina
app.post('/updateUserProfile', authenticateToken, async (req, res) => {
  console.log('LLEGA updateUserProfile POST', req.body);
  const { username, sexo, bomba_insulina } = req.body;
  try {
    console.log('Intentando actualizar usuario:', username, 'sexo:', sexo, 'bomba_insulina:', bomba_insulina);
    const { error } = await supabase
      .from('users')
      .update({ sexo: sexo, bomba_insulina: bomba_insulina })
      .eq('Username', username);
    if (error) throw error;
    res.status(200).json({ message: 'Perfil actualizado correctamente' });
  } catch (err) {
    console.error('Error en updateUserProfile:', err);
    res.status(500).json({ error: 'Error al actualizar el perfil' });
  }
});

app.put('/updateUserProfile', authenticateToken, async (req, res) => {
  console.log('LLEGA updateUserProfile PUT', req.body);
  const { username, sexo, bomba_insulina } = req.body;
  try {
    console.log('Intentando actualizar usuario:', username, 'sexo:', sexo, 'bomba_insulina:', bomba_insulina);
    const { error } = await supabase
      .from('users')
      .update({ sexo: sexo, bomba_insulina: bomba_insulina })
      .eq('Username', username);
    if (error) throw error;
    res.status(200).json({ message: 'Perfil actualizado correctamente' });
  } catch (err) {
    console.error('Error en updateUserProfile:', err);
    res.status(500).json({ error: 'Error al actualizar el perfil' });
  }
});

// Endpoint para obtener los registros de período de un usuario
app.get('/getPeriodRecords/:username', async (req, res) => {
  const { username } = req.params;
  try {
    const [periodData] = await supabase
      .from('periodrecords')
      .select('*')
      .eq('username', username)
      .order('startDate', { ascending: false });
    res.status(200).json({ periodData });
  } catch (error) {
    console.error('❌ Error al obtener registros de período:', error);
    res.status(500).send('Error al obtener los registros de período');
  }
});

// Endpoint para actualizar un registro de estado de ánimo
app.put('/updateMoodRecord', authenticateToken, async (req, res) => {
  try {
    let { id, mood_value, out_of_routine, routine_description, emotions, other_emotion, date_time } = req.body;
    const table = 'mooddata';
    
    // Asegurar que los valores no sean null/undefined antes de cifrar
    const safeRoutineDescription = routine_description ?? '';
    const safeOtherEmotion = other_emotion ?? '';
    let safeEmotions = emotions;
    if (!Array.isArray(safeEmotions)) {
      if (typeof safeEmotions === 'string') {
        try {
          safeEmotions = JSON.parse(safeEmotions);
        } catch (e) {
          safeEmotions = safeEmotions.split(',').map(e => e.trim()).filter(e => e !== '');
        }
      } else if (safeEmotions == null) {
        safeEmotions = [];
      } else {
        safeEmotions = [safeEmotions];
      }
    }
    // Filtrar nulos y vacíos
    safeEmotions = safeEmotions.filter(e => typeof e === 'string' && e.trim() !== '');
    
    const encRoutineDescription = encryptOrMark(safeRoutineDescription, table, 'routine_description');
    const encOtherEmotion = encryptOrMark(safeOtherEmotion, table, 'other_emotion');
    const encEmotions = safeEmotions.map(e => encryptOrMark(e, table, 'emotions'));
    
    const { error } = await supabase
      .from('mooddata')
      .update({
        mood_value,
        out_of_routine,
        routine_description: encRoutineDescription.encryptedData,
        routine_description_iv: encRoutineDescription.iv,
        emotions: encEmotions.map(e => e.encryptedData),
        emotions_iv: encEmotions.map(e => e.iv),
        other_emotion: encOtherEmotion.encryptedData,
        other_emotion_iv: encOtherEmotion.iv,
        date_time
      })
      .eq('id', id);
    if (error) {
      console.error('[updateMoodRecord] Error al actualizar:', error);
      throw error;
    }
    res.status(200).send('Registro de estado de ánimo actualizado correctamente');
  } catch (error) {
    console.error('❌ Error al actualizar el registro de estado de ánimo:', error);
    res.status(500).send('Error al actualizar el registro de estado de ánimo');
  }
});

// Iniciar servidor sin depender de conexión exitosa
app.get('/allData/:username', async (req, res) => {
  const { username } = req.params;
  console.log('[allData] Nombre de usuario recibido:', username);
  try {
    const insulinRes = await supabase
      .from('insulindata')
      .select('id, insulinType, insulintype_iv, dose, dose_iv, date_time, actualDateTime')
      .eq('username', username);
    const foodRes = await supabase
      .from('fooddata')
      .select('id, food_type, food_type_iv, quantity, quantity_iv, carbs, carbs_iv, date_time')
      .eq('username', username);
    const exerciseRes = await supabase
      .from('exercisedata')
      .select('id, exercise_type, exercise_type_iv, intensity, exercise_start_time, exercise_end_time, exercise_description, exercise_description_iv, date_time')
      .eq('username', username)
      .order('date_time', { ascending: true });
    const periodRes = await supabase
      .from('periodrecords')
      .select('id, startDate, endDate, intensity, intensity_iv, symptoms, symptoms_iv, notes, notes_iv, date_time')
      .eq('username', username)
      .order('startDate', { ascending: false });
    const moodRes = await supabase
      .from('mooddata')
      .select('id, username, mood_value, out_of_routine, routine_description, routine_description_iv, emotions, emotions_iv, other_emotion, other_emotion_iv, date_time')
      .eq('username', username)
      .order('date_time', { ascending: false });

    // Log de depuración para ver los datos crudos de mooddata
    console.log('moodRes.data:', moodRes.data);

    // Descifrar los datos
    const insulinData = (insulinRes.data || []).map(item => ({
      ...item,
      insulinType: decryptOrPlain(item.insulinType, item.insulintype_iv),
      dose: decryptOrPlain(item.dose, item.dose_iv),
      // date_time no se descifra
    }));
    const foodData = (foodRes.data || []).map(item => ({
      ...item,
      food_type: decryptOrPlain(item.food_type, item.food_type_iv),
      quantity: decryptOrPlain(item.quantity, item.quantity_iv),
      carbs: decryptOrPlain(item.carbs, item.carbs_iv),
      // date_time no se descifra
    }));
    const exerciseData = (exerciseRes.data || []).map(item => ({
      ...item,
      exercise_type: decryptOrPlain(item.exercise_type, item.exercise_type_iv),
      exercise_description: decryptOrPlain(item.exercise_description, item.exercise_description_iv),
      // Fechas no se descifran
    }));
    const periodData = (periodRes.data || []).map(item => {
      // Asegurar que symptoms es un array
      let symptomsArr = item.symptoms;
      if (typeof symptomsArr === 'string') {
        symptomsArr = symptomsArr.split(',').map(s => s.trim()).filter(s => s !== '');
      }
      if (!Array.isArray(symptomsArr)) symptomsArr = [];
      let symptomsIvArr = item.symptoms_iv;
      if (typeof symptomsIvArr === 'string') {
        symptomsIvArr = symptomsIvArr.split(',').map(s => s.trim()).filter(s => s !== '');
      }
      if (!Array.isArray(symptomsIvArr)) symptomsIvArr = [];
      return {
        ...item,
        intensity: decryptOrPlain(item.intensity, item.intensity_iv),
        notes: decryptOrPlain(item.notes, item.notes_iv),
        symptoms: symptomsArr.map((s, idx) => (s ? decryptOrPlain(s, symptomsIvArr[idx]) : "")),
        // Fechas no se descifran
      };
    });
    const moodData = (moodRes.data || []).map(item => {
      // Asegurar que emotions y emotions_iv son arrays
      let emotionsArr = item.emotions;
      if (typeof emotionsArr === 'string') {
        try {
          emotionsArr = JSON.parse(emotionsArr);
        } catch (e) {
          emotionsArr = emotionsArr.split(',').map(e => e.trim()).filter(e => e !== '');
        }
      }
      if (!Array.isArray(emotionsArr)) emotionsArr = [];
      let emotionsIvArr = item.emotions_iv;
      if (typeof emotionsIvArr === 'string') {
        try {
          emotionsIvArr = JSON.parse(emotionsIvArr);
        } catch (e) {
          emotionsIvArr = emotionsIvArr.split(',').map(e => e.trim()).filter(e => e !== '');
        }
      }
      if (!Array.isArray(emotionsIvArr)) emotionsIvArr = [];
      return {
        id: item.id,
        username: item.username,
        mood_value: item.mood_value,
        out_of_routine: item.out_of_routine,
        routine_description: decryptOrPlain(item.routine_description, item.routine_description_iv),
        emotions: emotionsArr.map((e, idx) => (e ? decryptOrPlain(e, emotionsIvArr[idx]) : "")),
        other_emotion: item.other_emotion ? decryptOrPlain(item.other_emotion, item.other_emotion_iv) : "",
        date_time: item.date_time
      };
    });

    // Log de depuración para ver moodData
    console.log('moodData:', moodData);

    res.status(200).json({
      insulinData,
      foodData,
      exerciseData,
      periodData,
      moodData
    });
  } catch (error) {
    console.error('❌ Error al obtener datos:', error);
    res.status(500).send('Error al obtener los datos');
  }
});

// Endpoint para eliminar todos los datos de un usuario
app.delete('/deleteAllData/:username', authenticateToken, async (req, res) => {
  const { username } = req.params;
  console.log('Eliminando todos los datos para el usuario:', username);
  try {
    // Eliminar datos de insulina
    await supabase
      .from('insulindata')
      .delete()
      .eq('username', username);
    console.log('Datos de insulina eliminados');
    // Eliminar datos de comida
    await supabase
      .from('fooddata')
      .delete()
      .eq('username', username);
    console.log('Datos de comida eliminados');
    // Eliminar datos de ejercicio
    await supabase
      .from('exercisedata')
      .delete()
      .eq('username', username);
    console.log('Datos de ejercicio eliminados');
    // Eliminar datos de periodo
    await supabase
      .from('periodrecords')
      .delete()
      .eq('username', username);
    console.log('Datos de período eliminados');
    res.status(200).send('Todos los datos han sido eliminados correctamente');
  } catch (error) {
    console.error('❌ Error al eliminar los datos:', error);
    res.status(500).send('Error al eliminar los datos');
  }
});

// ==================== ENDPOINTS DE ELIMINACIÓN INDIVIDUAL ====================

// Endpoint para eliminar un registro de insulina específico
app.delete('/deleteInsulinRecord/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  console.log('Eliminando registro de insulina con ID:', id);
  
  try {
    const { data, error } = await supabase
      .from('insulindata')
      .delete()
      .eq('id', id);
    
    if (error) {
      console.error('❌ Error al eliminar registro de insulina:', error);
      return res.status(500).json({ error: 'Error al eliminar el registro de insulina' });
    }
    
    console.log('✅ Registro de insulina eliminado correctamente');
    res.status(200).json({ message: 'Registro de insulina eliminado correctamente' });
  } catch (error) {
    console.error('❌ Error al eliminar registro de insulina:', error);
    res.status(500).json({ error: 'Error al eliminar el registro de insulina' });
  }
});

// Endpoint para eliminar un registro de comida específico
app.delete('/deleteFoodRecord/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  console.log('Eliminando registro de comida con ID:', id);
  
  try {
    const { data, error } = await supabase
      .from('fooddata')
      .delete()
      .eq('id', id);
    
    if (error) {
      console.error('❌ Error al eliminar registro de comida:', error);
      return res.status(500).json({ error: 'Error al eliminar el registro de comida' });
    }
    
    console.log('✅ Registro de comida eliminado correctamente');
    res.status(200).json({ message: 'Registro de comida eliminado correctamente' });
  } catch (error) {
    console.error('❌ Error al eliminar registro de comida:', error);
    res.status(500).json({ error: 'Error al eliminar el registro de comida' });
  }
});

// Endpoint para eliminar un registro de ejercicio específico
app.delete('/deleteExerciseRecord/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  console.log('Eliminando registro de ejercicio con ID:', id);
  
  try {
    const { data, error } = await supabase
      .from('exercisedata')
      .delete()
      .eq('id', id);
    
    if (error) {
      console.error('❌ Error al eliminar registro de ejercicio:', error);
      return res.status(500).json({ error: 'Error al eliminar el registro de ejercicio' });
    }
    
    console.log('✅ Registro de ejercicio eliminado correctamente');
    res.status(200).json({ message: 'Registro de ejercicio eliminado correctamente' });
  } catch (error) {
    console.error('❌ Error al eliminar registro de ejercicio:', error);
    res.status(500).json({ error: 'Error al eliminar el registro de ejercicio' });
  }
});

// Endpoint para eliminar un registro de período específico
app.delete('/deletePeriodRecord/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  console.log('Eliminando registro de período con ID:', id);
  
  try {
    const { data, error } = await supabase
      .from('periodrecords')
      .delete()
      .eq('id', id);
    
    if (error) {
      console.error('❌ Error al eliminar registro de período:', error);
      return res.status(500).json({ error: 'Error al eliminar el registro de período' });
    }
    
    console.log('✅ Registro de período eliminado correctamente');
    res.status(200).json({ message: 'Registro de período eliminado correctamente' });
  } catch (error) {
    console.error('❌ Error al eliminar registro de período:', error);
    res.status(500).json({ error: 'Error al eliminar el registro de período' });
  }
});

// Endpoint para eliminar un registro de estado de ánimo específico
app.delete('/deleteMoodRecord/:id', authenticateToken, async (req, res) => {
  const { id } = req.params;
  console.log('Eliminando registro de estado de ánimo con ID:', id);
  
  try {
    const { data, error } = await supabase
      .from('mooddata')
      .delete()
      .eq('id', id);
    
    if (error) {
      console.error('❌ Error al eliminar registro de estado de ánimo:', error);
      return res.status(500).json({ error: 'Error al eliminar el registro de estado de ánimo' });
    }
    
    console.log('✅ Registro de estado de ánimo eliminado correctamente');
    res.status(200).json({ message: 'Registro de estado de ánimo eliminado correctamente' });
  } catch (error) {
    console.error('❌ Error al eliminar registro de estado de ánimo:', error);
    res.status(500).json({ error: 'Error al eliminar el registro de estado de ánimo' });
  }
});

// POLAR H10 DATA - Endpoint para datos del Polar H10
app.post('/polarData', authenticateToken, async (req, res) => {
  try {
    const { username, timestamp, heart_rate, rri_data, device_id, data_type } = req.body;
    
    // Validar datos requeridos
    if (!username || !timestamp || heart_rate == null) {
      return res.status(400).json({ error: 'Datos incompletos' });
    }

    // Insertar en tabla de datos del Polar H10
    const { data, error } = await supabase
      .from('polar_data')
      .insert([{
        username,
        timestamp,
        heart_rate: heart_rate,
        rri_data: rri_data || [],
        device_id: device_id || 'polar_h10',
        data_type: data_type || 'heart_rate_reading',
        created_at: new Date().toISOString()
      }]);

    if (error) {
      console.error('Error guardando datos del Polar H10:', error);
      throw error;
    }

    res.status(200).json({ 
      success: true, 
      message: 'Datos del Polar H10 guardados correctamente' 
    });
  } catch (error) {
    console.error('❌ Error al guardar datos del Polar H10:', error);
    res.status(500).json({ error: 'Error al guardar los datos del Polar H10' });
  }
});

// Endpoint para actualizar el consentimiento GDPR
app.post('/updateGDPRConsent', async (req, res) => {
  try {
    const { username, hasConsented } = req.body;

    // Actualizar el estado del consentimiento en la base de datos
    const { error } = await supabase
      .from('users')
      .update({ GDPRConsent: hasConsented, GDPRConsentDate: new Date() })
      .eq('Username', username);
    if (error) throw error;

    res.status(200).send('Consentimiento actualizado correctamente');
    console.log('✅ Consentimiento GDPR actualizado para el usuario:', username);
  } catch (error) {
    console.error('❌ Error al actualizar el consentimiento:', error);
    res.status(500).send('Error al actualizar el consentimiento');
  }
});

// Endpoint para revocar el consentimiento GDPR (sin eliminar datos)
app.post('/revokeGDPRConsent', authenticateToken, async (req, res) => {
  try {
    const { username } = req.body;

    // Solo actualizar el estado del consentimiento
    const { error } = await supabase
      .from('users')
      .update({ GDPRConsent: false, GDPRConsentDate: null })
      .eq('Username', username);
    if (error) throw error;

    res.status(200).send('Consentimiento revocado correctamente');
    console.log('✅ Consentimiento GDPR revocado para el usuario:', username);
  } catch (error) {
    console.error('❌ Error al revocar el consentimiento:', error);
    res.status(500).send('Error al revocar el consentimiento');
  }
});

// Endpoint para cambiar la contraseña
app.post('/changePassword', async (req, res) => {
  try {
    const { username, newPassword } = req.body;

    // Cifrar la nueva contraseña
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(newPassword, salt);

    // Actualizar la contraseña en la base de datos
    const { error } = await supabase
      .from('users')
      .update({ PasswordHash: passwordHash })
      .eq('Username', username);
    if (error) throw error;

    res.status(200).send('Contraseña actualizada correctamente');
    console.log('✅ Contraseña actualizada para el usuario:', username);
  } catch (error) {
    console.error('❌ Error al cambiar la contraseña:', error);
    res.status(500).send('Error al cambiar la contraseña');
  }
});

// Endpoint para descifrar datos individuales
app.post('/decrypt', async (req, res) => {
  try {
    const { encryptedData, iv } = req.body
    
    if (!encryptedData) {
      return res.status(400).json({ error: 'Datos cifrados requeridos' })
    }
    
    // Si no hay IV o el texto empieza con __PLAIN__, es texto plano
    if (!iv || encryptedData.startsWith('__PLAIN__')) {
      const plainText = encryptedData.startsWith('__PLAIN__') 
        ? encryptedData.replace('__PLAIN__', '') 
        : encryptedData
      return res.json({ decryptedData: plainText })
    }
    
    // Descifrar usando la función existente
    const decryptedData = decryptOrPlain(encryptedData, iv)
    
    res.json({ decryptedData })
  } catch (error) {
    console.error('Error al descifrar:', error)
    res.status(500).json({ error: 'Error al descifrar datos' })
  }
})

const port = 3000;
app.listen(port, () => {
  console.log(`🚀 Servidor escuchando en http://localhost:${port}`);
});

// Test de conexión a Supabase/PostgreSQL
(async () => {
  try {
    await supabase.from('users').select('*');
    console.log('✅ Conexión a Supabase/PostgreSQL exitosa');
  } catch (err) {
    console.error('❌ Error conectando a Supabase/PostgreSQL:', err);
  }
})();

// Función para truncar fechas a milisegundos (3 decimales)
function truncateDateToMs(dateInput) {
if (!dateInput) return null;
  const date = new Date(dateInput);
  // Formato: 'YYYY-MM-DD HH:mm:ss'
  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  const hh = String(date.getHours()).padStart(2, '0');
  const min = String(date.getMinutes()).padStart(2, '0');
  const ss = String(date.getSeconds()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd} ${hh}:${min}:${ss}`;
}

// Cifrado de texto
function encrypt(text) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(algorithm, Buffer.from(secretKey, 'hex'), iv);
  let encrypted = cipher.update(text, 'utf-8', 'hex');
  encrypted += cipher.final('hex');
  return { iv: iv.toString('hex'), encryptedData: encrypted };
}

// Log de ejemplo de cómo se vería un texto encriptado
if (secretKey) {
  const ejemplo = encrypt('ejemplo de texto');
  console.log('[EJEMPLO ENCRIPTADO] Texto original: ejemplo de texto');
  console.log('[EJEMPLO ENCRIPTADO] encryptedData:', ejemplo.encryptedData);
  console.log('[EJEMPLO ENCRIPTADO] iv:', ejemplo.iv);
}

// Descifrado de texto con fallback ENCRYPTION_SECRET_KEY0 -> ENCRYPTION_SECRET_KEY
function decrypt(encryptedData, iv) {
  // Clave vieja (la que se usaba antes)
  const oldKey = process.env.ENCRYPTION_SECRET_KEY0 || '12345678901234567890123456789012';
  // Clave nueva (actual)
  const currentKey = process.env.ENCRYPTION_SECRET_KEY;

  // Función auxiliar para intentar descifrar con una clave
  function tryDecrypt(key, data, iv) {
    try {
      const decipher = crypto.createDecipheriv(algorithm, Buffer.from(key, 'hex'), Buffer.from(iv, 'hex'));
      let decrypted = decipher.update(data, 'hex', 'utf-8');
      decrypted += decipher.final('utf-8');
      return decrypted;
    } catch (error) {
      return null;
    }
  }

  // Intentar primero con la clave vieja
  let result = tryDecrypt(oldKey, encryptedData, iv);
  if (result) {
    // Si el resultado sigue siendo hexadecimal largo (doble-cifrado), intentar descifrar de nuevo
    if (/^[0-9a-fA-F]+$/.test(result) && result.length > 32) {
      console.log('🔄 Detectado doble-cifrado con clave vieja, descifrando de nuevo...');
      console.log('🔄 Primer descifrado:', result.substring(0, 50) + '...');
      // Intentar descifrar de nuevo con la misma clave
      const doubleResult = tryDecrypt(oldKey, result, iv);
      if (doubleResult) {
        console.log('🔄 Segundo descifrado:', doubleResult);
        return doubleResult;
      }
    }
    console.log('✅ Descifrado con clave vieja:', result);
    return result;
  }

  // Si falla con la clave vieja, intentar con la clave nueva
  result = tryDecrypt(currentKey, encryptedData, iv);
  if (result) {
    // Si el resultado sigue siendo hexadecimal largo (doble-cifrado), intentar descifrar de nuevo
    if (/^[0-9a-fA-F]+$/.test(result) && result.length > 32) {
      console.log('🔄 Detectado doble-cifrado con clave nueva, descifrando de nuevo...');
      console.log('🔄 Primer descifrado:', result.substring(0, 50) + '...');
      // Intentar descifrar de nuevo con la misma clave
      const doubleResult = tryDecrypt(currentKey, result, iv);
      if (doubleResult) {
        console.log('🔄 Segundo descifrado:', doubleResult);
        return doubleResult;
      }
    }
    console.log('✅ Descifrado con clave nueva:', result);
    return result;
  }

  throw new Error('No se pudo descifrar con ninguna clave');
}
