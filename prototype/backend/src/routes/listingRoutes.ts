import { Router } from 'express';
import * as listingController from '../controllers/listingController';

const router = Router();

router.get('/listings', listingController.listListings);
router.get('/listings/:id', listingController.getListing);
router.post('/listings', listingController.createListing);
router.put('/listings/:id', listingController.updateListing);
router.patch('/listings/:id/status', listingController.changeListingStatus);

export default router;
