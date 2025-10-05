#!/usr/bin/env bash
set -euo pipefail

# scripts/dev-verify.sh
# Automate: create product->price->customer->session, grant access, verify session and print JWT

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR"

# Load stripe key from env or .env.local
STRIPE_KEY=${STRIPE_SECRET_KEY:-}
if [ -z "$STRIPE_KEY" ]; then
  STRIPE_KEY=$(grep '^STRIPE_SECRET_KEY=' .env.local | cut -d= -f2- 2>/dev/null || true)
fi

if [ -z "$STRIPE_KEY" ]; then
  echo "STRIPE_SECRET_KEY not set in environment or .env.local"
  exit 1
fi

# Load admin token from env or .env.local
ADMIN_TOKEN=${ADMIN_ONBOARD_TOKEN:-}
if [ -z "$ADMIN_TOKEN" ]; then
  ADMIN_TOKEN=$(grep '^ADMIN_ONBOARD_TOKEN=' .env.local | cut -d= -f2- 2>/dev/null || true)
fi

if [ -z "$ADMIN_TOKEN" ]; then
  echo "ADMIN_ONBOARD_TOKEN not set in environment or .env.local"
  exit 1
fi

echo "Using STRIPE key prefix: ${STRIPE_KEY:0:8}..."

echo "1) Creating product"
curl -s -X POST https://api.stripe.com/v1/products -u "$STRIPE_KEY": \
  -d "name=V2U Dev Product" -d "description=Automated dev product" -o stripe-product.json
PRODUCT_ID=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' stripe-product.json | head -n1)
echo "PRODUCT_ID=$PRODUCT_ID"

echo "2) Creating price"
curl -s -X POST https://api.stripe.com/v1/prices -u "$STRIPE_KEY": \
  -d "unit_amount=500" -d "currency=usd" -d "product=$PRODUCT_ID" -o stripe-price.json
PRICE_ID=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' stripe-price.json | head -n1)
echo "PRICE_ID=$PRICE_ID"

echo "3) Creating customer"
curl -s -X POST https://api.stripe.com/v1/customers -u "$STRIPE_KEY": \
  --data-urlencode "email=dev+test@example.com" -o stripe-customer.json
CUSTOMER_ID=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' stripe-customer.json | head -n1)
echo "CUSTOMER_ID=$CUSTOMER_ID"

echo "4) Creating checkout session"
curl -s -X POST https://api.stripe.com/v1/checkout/sessions -u "$STRIPE_KEY": \
  -d "success_url=http://localhost:3000/?session_id={CHECKOUT_SESSION_ID}" \
  -d "cancel_url=http://localhost:3000/" \
  -d "payment_method_types[]=card" \
  -d "mode=payment" \
  -d "customer=$CUSTOMER_ID" \
  -d "line_items[0][price]=$PRICE_ID" \
  -d "line_items[0][quantity]=1" -o stripe-session.json
SESSION_ID=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' stripe-session.json | head -n1)
echo "SESSION_ID=$SESSION_ID"

echo "5) Granting access via admin endpoint"
curl -s -L -X POST http://localhost:3000/api/admin-grant-access/ \
  -H "Content-Type: application/json" \
  -d '{"token":"'#!/usr/bin/env bash
set -euo pipefail

# scripts/dev-verify.sh
# Automate: create product->price->customer->session, grant access, verify session and print JWT

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR"

STRIPE_KEY=${STRIPE_SECRET_KEY:-}
if [ -z "$STRIPE_KEY" ]; then
  STRIPE_KEY=$(grep '^STRIPE_SECRET_KEY=' .env.local | cut -d= -f2- 2>/dev/null || true)
fi

if [ -z "$STRIPE_KEY" ]; then
  echo "STRIPE_SECRET_KEY not set in environment or .env.local"
  exit 1
fi

ADMIN_TOKEN=${ADMIN_ONBOARD_TOKEN:-}
if [ -z "$ADMIN_TOKEN" ]; then
  ADMIN_TOKEN=$(grep '^ADMIN_ONBOARD_TOKEN=' .env.local | cut -d= -f2- 2>/dev/null || true)
fi

if [ -z "$ADMIN_TOKEN" ]; then
  echo "ADMIN_ONBOARD_TOKEN not set in environment or .env.local"
  exit 1
fi

echo "Using STRIPE key prefix: ${STRIPE_KEY:0:8}..."

echo "1) Creating product"
curl -s -X POST https://api.stripe.com/v1/products -u "$STRIPE_KEY": \
  -d "name=V2U Dev Product" -d "description=Automated dev product" -o stripe-product.json
PRODUCT_ID=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' stripe-product.json | head -n1)
echo "PRODUCT_ID=$PRODUCT_ID"

echo "2) Creating price"
curl -s -X POST https://api.stripe.com/v1/prices -u "$STRIPE_KEY": \
  -d "unit_amount=500" -d "currency=usd" -d "product=$PRODUCT_ID" -o stripe-price.json
PRICE_ID=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' stripe-price.json | head -n1)
echo "PRICE_ID=$PRICE_ID"

echo "3) Creating customer"
curl -s -X POST https://api.stripe.com/v1/customers -u "$STRIPE_KEY": \
  --data-urlencode "email=dev+test@example.com" -o stripe-customer.json
CUSTOMER_ID=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' stripe-customer.json | head -n1)
echo "CUSTOMER_ID=$CUSTOMER_ID"

echo "4) Creating checkout session"
curl -s -X POST https://api.stripe.com/v1/checkout/sessions -u "$STRIPE_KEY": \
  -d "success_url=http://localhost:3000/?session_id={CHECKOUT_SESSION_ID}" \
  -d "cancel_url=http://localhost:3000/" \
  -d "payment_method_types[]=card" \
  -d "mode=payment" \
  -d "customer=$CUSTOMER_ID" \
  -d "line_items[0][price]=$PRICE_ID" \
  -d "line_items[0][quantity]=1" -o stripe-session.json
SESSION_ID=$(sed -n 's/.*"id": *"\([^"]*\)".*/\1/p' stripe-session.json | head -n1)
echo "SESSION_ID=$SESSION_ID"

echo "5) Granting access via admin endpoint"
curl -s -L -X POST http://localhost:3000/api/admin-grant-access/ \
  -H "Content-Type: application/json" \
  -d '{"token":"'"$ADMIN_TOKEN"'","customerId":"'"$CUSTOMER_ID"'"}' \
  -o admin-grant-access.json -w "\nHTTP:%{http_code}\n"

cat admin-grant-access.json

echo "6) Verifying session"
curl -s -L "http://localhost:3000/api/verify-session/?session_id=$SESSION_ID" -o verify-session.json -w "\nHTTP:%{http_code}\n"
cat verify-session.json

echo "Done. If granted:true and jwt present, you can use the JWT in the TOKEN variable below."
TOKEN=$(node -e "console.log(require('./verify-session.json').jwt)")
echo "JWT prefix: ${TOKEN:0:12}..."
echo "To call private endpoints: curl -H \"Authorization: Bearer $TOKEN\" http://localhost:3000/api/r2/private/..."