import { Router, Request, Response } from 'express';
import { pool } from '../db';

const router = Router();

router.get('/categories', async (_req: Request, res: Response) => {
  try {
    const result = await pool.query(
      `SELECT id, name, slug
       FROM categories
       WHERE is_active = true
       ORDER BY sort_order`
    );
    res.json(result.rows);
  } catch {
    res.status(500).json({ error: 'Andmebaasiviga' });
  }
});

export default router;
