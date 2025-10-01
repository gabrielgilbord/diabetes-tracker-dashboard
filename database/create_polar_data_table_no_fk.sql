-- Crear tabla para datos del Polar H10 recogidos automáticamente (sin foreign key)
CREATE TABLE IF NOT EXISTS polar_data (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    heart_rate INTEGER NOT NULL,
    rri_data JSONB, -- Array de valores RRi
    device_id TEXT DEFAULT 'polar_h10',
    data_type TEXT DEFAULT 'heart_rate_reading',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejorar consultas
CREATE INDEX IF NOT EXISTS idx_polar_data_username ON polar_data(username);
CREATE INDEX IF NOT EXISTS idx_polar_data_timestamp ON polar_data(timestamp);
CREATE INDEX IF NOT EXISTS idx_polar_data_username_timestamp ON polar_data(username, timestamp);
CREATE INDEX IF NOT EXISTS idx_polar_data_heart_rate ON polar_data(heart_rate);

-- Comentarios para documentación
COMMENT ON TABLE polar_data IS 'Datos de frecuencia cardíaca y RRi del Polar H10 recogidos automáticamente';
COMMENT ON COLUMN polar_data.username IS 'Nombre de usuario que posee los datos';
COMMENT ON COLUMN polar_data.timestamp IS 'Timestamp de la medición';
COMMENT ON COLUMN polar_data.heart_rate IS 'Frecuencia cardíaca en bpm';
COMMENT ON COLUMN polar_data.rri_data IS 'Array de valores RRi (R-R intervals) en milisegundos';
COMMENT ON COLUMN polar_data.device_id IS 'Identificador del dispositivo (polar_h10)';
COMMENT ON COLUMN polar_data.data_type IS 'Tipo de dato (heart_rate_reading)';
COMMENT ON COLUMN polar_data.created_at IS 'Timestamp de creación del registro en la base de datos'; 