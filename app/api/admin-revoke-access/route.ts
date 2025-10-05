import { NextRequest, NextResponse } from 'next/server';
import { revokeAccess } from '@/lib/kv-client';

// POST /api/admin-revoke-access
// Body: { token: string, customerId: string }
export async function POST(request: NextRequest) {
  try {
    const body = await request.json() as { token?: string; customerId?: string };
    const serverToken = process.env.ADMIN_ONBOARD_TOKEN;
    if (!serverToken) {
      return NextResponse.json({ error: 'Server onboarding token not configured' }, { status: 500 });
    }
    if (!body.token || body.token !== serverToken) {
      return NextResponse.json({ error: 'Invalid onboarding token' }, { status: 401 });
    }
    if (!body.customerId) return NextResponse.json({ error: 'customerId required' }, { status: 400 });

    await revokeAccess(body.customerId);
    return NextResponse.json({ success: true, customerId: body.customerId });
  } catch (err) {
    console.error('Admin revoke-access error:', err);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
