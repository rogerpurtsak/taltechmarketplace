import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3001'),
  db: {
    host: process.env.DB_HOST || 'apex2.taltech.ee',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 't233226',
    user: process.env.DB_USER || 't233226',
    password: process.env.DB_PASSWORD || '',
    ssl: { rejectUnauthorized: false },
  },
  demoSellerId: process.env.DEMO_SELLER_ID || '',
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:5173',
};
