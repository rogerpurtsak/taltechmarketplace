import fs from 'fs';
import path from 'path';
import { pool } from './db';

async function seed() {
  const sqlPath = path.join(__dirname, '..', 'sql', 'seed_demo_data.sql');
  const sql = fs.readFileSync(sqlPath, 'utf-8');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('COMMIT');
    console.log('✓ Demoandmed lisatud edukalt.');
    console.log('  Demo müüja UUID: aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa');
    console.log('  Lisa see .env faili: DEMO_SELLER_ID=aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('✗ Seed ebaõnnestus:', err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
