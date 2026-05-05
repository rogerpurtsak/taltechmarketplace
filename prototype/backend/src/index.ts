import express from 'express';
import cors from 'cors';
import { config } from './config';
import healthRoutes from './routes/healthRoutes';
import categoryRoutes from './routes/categoryRoutes';
import conditionRoutes from './routes/conditionRoutes';
import listingRoutes from './routes/listingRoutes';

const app = express();

app.use(cors({ origin: config.corsOrigin }));
app.use(express.json());

app.use('/api', healthRoutes);
app.use('/api', categoryRoutes);
app.use('/api', conditionRoutes);
app.use('/api', listingRoutes);

app.listen(config.port, () => {
  console.log(`Backend töötab aadressil http://localhost:${config.port}`);
  console.log(`Demo müüja ID: ${config.demoSellerId || '(pole seadistatud)'}`);
});
