-- ⚠️ 생성물(파생) — 직접 수정 금지. 단일 출처는 docs/erd-signup.dbml
-- 재생성: npx -p @dbml/cli dbml2sql docs/erd-signup.dbml --postgres -o docs/erd-signup.sql
-- 용도: DrawDB(또는 다른 ERD 에디터) Import from SQL(PostgreSQL)
-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-06-16T00:42:18.263Z

CREATE TYPE "user_status" AS ENUM (
  'pending',
  'active',
  'suspended',
  'deleted'
);

CREATE TYPE "auth_provider" AS ENUM (
  'password',
  'google',
  'apple',
  'kakao'
);

CREATE TYPE "token_purpose" AS ENUM (
  'email_verify',
  'password_reset',
  'magic_link'
);

CREATE TYPE "auth_event_type" AS ENUM (
  'signup',
  'login',
  'login_failed',
  'logout',
  'pw_reset'
);

CREATE TABLE "users" (
  "id" uuid PRIMARY KEY,
  "email" citext UNIQUE NOT NULL,
  "email_verified_at" timestamptz,
  "status" user_status NOT NULL DEFAULT 'pending',
  "display_name" text,
  "created_at" timestamptz NOT NULL,
  "updated_at" timestamptz NOT NULL,
  "deleted_at" timestamptz
);

CREATE TABLE "user_profiles" (
  "user_id" uuid PRIMARY KEY,
  "avatar_url" text,
  "bio" text,
  "locale" text,
  "timezone" text,
  "preferences" jsonb,
  "updated_at" timestamptz
);

CREATE TABLE "auth_identities" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "provider" auth_provider NOT NULL,
  "provider_uid" text,
  "password_hash" text,
  "last_used_at" timestamptz,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE "roles" (
  "id" uuid PRIMARY KEY,
  "name" text UNIQUE NOT NULL,
  "description" text
);

CREATE TABLE "user_roles" (
  "user_id" uuid,
  "role_id" uuid,
  "granted_at" timestamptz NOT NULL,
  PRIMARY KEY ("user_id", "role_id")
);

CREATE TABLE "sessions" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "refresh_token_hash" text UNIQUE NOT NULL,
  "user_agent" text,
  "ip_address" inet,
  "expires_at" timestamptz NOT NULL,
  "revoked_at" timestamptz,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE "auth_tokens" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "purpose" token_purpose NOT NULL,
  "token_hash" text UNIQUE NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz,
  "created_at" timestamptz NOT NULL
);

CREATE TABLE "auth_events" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid,
  "event_type" auth_event_type NOT NULL,
  "ip_address" inet,
  "user_agent" text,
  "metadata" jsonb,
  "created_at" timestamptz NOT NULL
);

CREATE UNIQUE INDEX ON "auth_identities" ("provider", "provider_uid");

COMMENT ON COLUMN "users"."email" IS '로그인 ID, 소문자 비교';

COMMENT ON COLUMN "users"."email_verified_at" IS '검증 진실의 출처';

COMMENT ON COLUMN "users"."status" IS '상태기계';

COMMENT ON COLUMN "users"."deleted_at" IS 'soft delete=가역성';

COMMENT ON COLUMN "user_profiles"."user_id" IS 'users 1:1 확장';

COMMENT ON COLUMN "user_profiles"."preferences" IS '확장 여지';

COMMENT ON COLUMN "auth_identities"."provider_uid" IS '소셜 고유 ID';

COMMENT ON COLUMN "auth_identities"."password_hash" IS 'password일 때만';

COMMENT ON COLUMN "roles"."name" IS 'user|admin|...';

COMMENT ON COLUMN "sessions"."refresh_token_hash" IS '원문 저장 금지';

COMMENT ON COLUMN "auth_tokens"."consumed_at" IS '1회용 소비 표시';

COMMENT ON COLUMN "auth_events"."user_id" IS 'nullable: 실패 로그인';

ALTER TABLE "user_profiles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "auth_identities" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "user_roles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "user_roles" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "sessions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "auth_tokens" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "auth_events" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL DEFERRABLE INITIALLY IMMEDIATE;
