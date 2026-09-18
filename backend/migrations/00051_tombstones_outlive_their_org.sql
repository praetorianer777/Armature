-- +goose Up
-- A tombstone is the bytes left in the bucket after their rows are gone. When
-- the organization itself is deleted, cascading the tombstones with it would
-- forget exactly the objects nobody will ever reach again, so they now stay
-- behind with no organization, for the reaper, which reads across tenants.

ALTER TABLE attachment_tombstone ALTER COLUMN org_id DROP NOT NULL;
ALTER TABLE attachment_tombstone DROP CONSTRAINT attachment_tombstone_org_id_fkey;
ALTER TABLE attachment_tombstone
    ADD CONSTRAINT attachment_tombstone_org_id_fkey
    FOREIGN KEY (org_id) REFERENCES org(id) ON DELETE SET NULL;

-- +goose Down
DELETE FROM attachment_tombstone WHERE org_id IS NULL;
ALTER TABLE attachment_tombstone DROP CONSTRAINT attachment_tombstone_org_id_fkey;
ALTER TABLE attachment_tombstone
    ADD CONSTRAINT attachment_tombstone_org_id_fkey
    FOREIGN KEY (org_id) REFERENCES org(id) ON DELETE CASCADE;
ALTER TABLE attachment_tombstone ALTER COLUMN org_id SET NOT NULL;
