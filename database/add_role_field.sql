-- Agregar campo role a la tabla users
-- Ejecutar en Supabase SQL Editor

-- 1. Agregar la columna role
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'doctor', 'user'));

-- 2. Crear índice para mejorar consultas por rol
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- 3. Actualizar usuarios existentes (opcional)
-- Asignar rol de admin al primer usuario o usuarios específicos
UPDATE users 
SET role = 'admin' 
WHERE Username IN ('admin', 'H2Train-Participant1') 
AND role = 'user';

-- 4. Comentarios para documentación
COMMENT ON COLUMN users.role IS 'Rol del usuario: admin (administrador), doctor (médico), user (usuario normal)';

-- 5. Verificar la estructura
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'role';
