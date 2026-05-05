import { Router, Request, Response } from 'express';
import { pool } from '../db';

const router = Router();

router.get('/listing-conditions', async (_req: Request, res: Response) => {
  try {
    const result = await pool.query(
      `SELECT id, label, code_label AS "codeLabel"
       FROM listing_conditions
       ORDER BY sort_order`
    );
    res.json(result.rows);
  } catch {
    res.status(500).json({ error: 'Andmebaasiviga' });
  }
});

export default router;
