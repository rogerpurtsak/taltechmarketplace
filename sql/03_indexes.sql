-- 1. FOREIGN KEY INDEXES

-- Category links:
CREATE INDEX idx_categories_parent_id ON categories(parent_id);

--so basically what happens here:
-- It creates a database index named idx_categories_parent_id on the parent_id column of the categories table.

-- Listing links (Who is selling it? What category? What condition?):
CREATE INDEX idx_listings_seller_id ON listings(seller_id);
CREATE INDEX idx_listings_category_id ON listings(category_id);
CREATE INDEX idx_listings_condition_id ON listings(condition_id);

-- Connecting images and favorites to a specific listing:
CREATE INDEX idx_listing_images_listing_id ON listing_images(listing_id);
CREATE INDEX idx_favorites_listing_id ON favorites(listing_id);

-- Conversation links (Connecting the chat to the item, the buyer, and the seller):
CREATE INDEX idx_conversations_listing_id ON conversations(listing_id);
CREATE INDEX idx_conversations_buyer_id ON conversations(buyer_id);
CREATE INDEX idx_conversations_seller_id ON conversations(seller_id);

-- Message links (Connecting individual texts to the chat and the sender):
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);

-- Offer links:
CREATE INDEX idx_offers_listing_id ON offers(listing_id);
CREATE INDEX idx_offers_conversation_id ON offers(conversation_id);
CREATE INDEX idx_offers_buyer_id ON offers(buyer_id);

-- Order links:
CREATE INDEX idx_orders_listing_id ON orders(listing_id);
CREATE INDEX idx_orders_offer_id ON orders(offer_id);
CREATE INDEX idx_orders_buyer_id ON orders(buyer_id);
CREATE INDEX idx_orders_seller_id ON orders(seller_id);

-- 2. FUNCTIONAL INDEXES

-- For the Seller's dashboard (Searching by who they are + the status of the item):
CREATE INDEX idx_listings_seller_status ON listings(seller_id, status);

-- For the Seller's dashboard (Sorting their items by when they were created):
CREATE INDEX idx_listings_seller_created ON listings(seller_id, created_at);

-- For buyers browsing the public marketplace (Searching by category + active status):
CREATE INDEX idx_listings_category_status ON listings(category_id, status);

-- For the "Newest Items" page (Sorting all items by status and time):
CREATE INDEX idx_listings_status_created ON listings(status, created_at);

-- For sorting the inbox and chat histories chronologically:
CREATE INDEX idx_messages_conv_sent ON messages(conversation_id, sent_at);
CREATE INDEX idx_conversations_buyer_last_msg ON conversations(buyer_id, last_message_at);
CREATE INDEX idx_conversations_seller_last_msg ON conversations(seller_id, last_message_at);

-- 3. PARTIAL UNIQUE INDEX (Business Logic)

CREATE UNIQUE INDEX idx_orders_unique_active_listing 
ON orders(listing_id) 
WHERE status IN ('pending', 'confirmed', 'completed');

-- This partial unique index enforces business logic by allowing only one order per listing_id when the order is in an active/finalized state (pending, confirmed, or completed). It prevents duplicate valid orders for the same listing while still allowing multiple rows in non-active statuses (for example, cancelled).