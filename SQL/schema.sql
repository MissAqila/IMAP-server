-- Create database
CREATE DATABASE testdb;

-- Create user with password
CREATE USER admin WITH PASSWORD "admin";

-- Grant all privileges on the database to the user
GRANT ALL PRIVILEGES ON DATABASE testdb TO admin;

-- Connect to the database
\c testdb;

-- Grant all necessary permissions in the database
GRANT ALL ON SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin;

-- Make user a superuser for development (optional but helpful)
ALTER USER admin WITH SUPERUSER;

-- Grant create database privilege
ALTER USER admin CREATEDB;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO admin;

-- Create the inbox table (self-hosted, no longer using Supabase)
CREATE TABLE IF NOT EXISTS inbox (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email_address TEXT NOT NULL UNIQUE,
    user_id UUID,
    fingerprint TEXT, -- For cybertemp website you can remove it it will work anyway
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on email_address for faster lookups
CREATE INDEX IF NOT EXISTS idx_inbox_email_address ON inbox(email_address);

-- Grant privileges on the inbox table
GRANT ALL PRIVILEGES ON TABLE inbox TO admin;

-- Create the emails table
CREATE TABLE IF NOT EXISTS emails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mailbox_owner TEXT NOT NULL,
    mailbox TEXT NOT NULL DEFAULT 'INBOX',
    subject TEXT NOT NULL,
    -- `body` will contain the plain/text representation
    body TEXT NOT NULL,
    -- `html` will contain HTML representation when present (nullable)
    html TEXT,
    from_addr TEXT NOT NULL,
    to_addrs TEXT[] NOT NULL DEFAULT '{}',
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    flags TEXT[] NOT NULL DEFAULT '{}',
    size BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_emails_owner_mailbox ON emails(mailbox_owner, mailbox);
CREATE INDEX IF NOT EXISTS idx_emails_timestamp ON emails(timestamp);

-- Grant privileges on the emails table specifically
GRANT ALL PRIVILEGES ON TABLE emails TO admin;

-- Verify setup
\du
\l
\dt
