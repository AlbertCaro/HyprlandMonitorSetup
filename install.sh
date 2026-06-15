#!/bin/bash
set -euo pipefail

# Directorios destino
BIN_DIR="$HOME/.local/bin"
HYPR_DIR="$HOME/.config/hypr"

SCRIPT_NAME="monitor-setup"
HYPR_FILES=("monitors.one.conf" "monitors.two.conf")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helpers
msg()  { echo ":: $*"; }
err()  { echo "Error: $*" >&2; }
die()  { err "$*"; exit 1; }

# 1. Crear directorios si no existen
mkdir -p "$BIN_DIR" "$HYPR_DIR"

# 2. Copiar el script a ~/.local/bin
if [[ ! -f "$SCRIPT_DIR/$SCRIPT_NAME" ]]; then
  die "No se encontró '$SCRIPT_NAME' junto a este instalador."
fi

if [[ -f "$BIN_DIR/$SCRIPT_NAME" && "${1:-}" != "--force" ]]; then
  die "Ya existe '$BIN_DIR/$SCRIPT_NAME'. Usa --force para sobreescribir."
fi

cp "$SCRIPT_DIR/$SCRIPT_NAME" "$BIN_DIR/$SCRIPT_NAME"
chmod +x "$BIN_DIR/$SCRIPT_NAME"
msg "Instalado: $BIN_DIR/$SCRIPT_NAME"

# 3. Copiar los perfiles de monitores (sin sobreescribir los existentes)
for f in "${HYPR_FILES[@]}"; do
  src="$SCRIPT_DIR/$f"
  dst="$HYPR_DIR/$f"
  if [[ ! -f "$src" ]]; then
    err "Falta '$f' junto al instalador; se omite."
    continue
  fi
  if [[ -f "$dst" && "${1:-}" != "--force" ]]; then
    msg "Ya existe '$dst' (conservado). Usa --force para sobreescribir."
  else
    cp "$src" "$dst"
    msg "Instalado: $dst"
  fi
done

# 4. Verificar que monitors.conf existe (lo crea el usuario con nwg-displays)
if [[ ! -f "$HYPR_DIR/monitors.conf" ]]; then
  err "No se encontró '$HYPR_DIR/monitors.conf'."
  err "Genéralo con nwg-displays antes de usar switch-monitor."
fi

# 5. Verificar PATH
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) msg "Nota: '$BIN_DIR' no está en tu PATH. Añádelelo a tu shell." ;;
esac

echo
msg "Listo. Ejecuta 'monitor-setup' para alternar perfiles."
