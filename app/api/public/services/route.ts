export const dynamic = "force-dynamic";
export const revalidate = 0;

import { NextResponse } from "next/server";
import { readServicesList } from "@/lib/services";

export async function GET() {
  try {
    const services = await readServicesList(false);

    return NextResponse.json({
      ok: true,
      services,
    });
  } catch (error: any) {
    console.error("Public services error:", {
      message: error?.message,
      stack: error?.stack,
    });

    return NextResponse.json(
      {
        ok: false,
        error: error?.message || "Errore caricamento servizi",
      },
      { status: 500 }
    );
  }
}