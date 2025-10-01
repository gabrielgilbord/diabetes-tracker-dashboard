-- Añadir campos de consentimiento GDPR a la tabla Users
ALTER TABLE Users
ADD COLUMN GDPRConsent BOOLEAN DEFAULT FALSE,
ADD COLUMN GDPRConsentDate DATETIME NULL;
 
-- Actualizar los usuarios existentes para que tengan consentimiento por defecto
UPDATE Users
SET GDPRConsent = TRUE,
    GDPRConsentDate = CURRENT_TIMESTAMP
WHERE GDPRConsent IS NULL; 