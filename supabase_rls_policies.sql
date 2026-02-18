-- Run this in Supabase: SQL Editor → New query → paste → Run
-- This allows the anon key (your app) to SELECT, INSERT, UPDATE, DELETE on orders, products, and clients.

-- Products: allow anon to do everything (for demo; tighten in production)
CREATE POLICY "Allow anon all on products"
  ON products FOR ALL TO anon
  USING (true)
  WITH CHECK (true);

-- Orders: allow anon to do everything
CREATE POLICY "Allow anon all on orders"
  ON orders FOR ALL TO anon
  USING (true)
  WITH CHECK (true);

-- Clients: allow anon to do everything
CREATE POLICY "Allow anon all on clients"
  ON clients FOR ALL TO anon
  USING (true)
  WITH CHECK (true);
