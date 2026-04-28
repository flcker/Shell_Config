################################################################################
# 归档工具：extract / archive
# x [-o <outdir>] <file> [...]          解压，-o 指定输出目录
# a <output> [-C <srcdir>] [file ...]   打包或压缩，-C 指定源目录

# ── extract ───────────────────────────────────────────────────────────────────
function extract() {
  (( $# )) || {
    echo "usage: x [-o <outdir>] <file> [...]"
    echo "formats: tar.gz tar.bz2 tar.xz tar.zst tar gz bz2 xz zst zip rar 7z Z"
    return 0
  }
  local outdir=.
  [[ $1 == -o ]] && { outdir=$2; shift 2; mkdir -p "$outdir" }
  local f absf
  for f; do
    [[ -f $f ]] || { print -u2 "x: '$f' not found"; continue }
    [[ $f == /* ]] && absf=$f || absf="$PWD/$f"
    case $f in
      *.tar.gz|*.tgz)   tar xzf "$absf" -C "$outdir" ;;
      *.tar.bz2|*.tbz2) tar xjf "$absf" -C "$outdir" ;;
      *.tar.xz)         tar xJf "$absf" -C "$outdir" ;;
      *.tar.zst)        tar --use-compress-program=unzstd -xf "$absf" -C "$outdir" ;;
      *.tar)            tar xf  "$absf" -C "$outdir" ;;
      *.gz)             gunzip  -c "$absf" > "$outdir/${f:t:r}" ;;
      *.bz2)            bunzip2 -c "$absf" > "$outdir/${f:t:r}" ;;
      *.xz)             xz   -dc "$absf" > "$outdir/${f:t:r}" ;;
      *.zst)            unzstd  -c "$absf" > "$outdir/${f:t:r}" ;;
      *.Z)              uncompress -c "$absf" > "$outdir/${f:t:r}" ;;
      *.zip)            unzip   "$absf" -d "$outdir" ;;
      *.rar)            unrar x "$absf" "$outdir/" ;;
      *.7z)             7za x   "$absf" -o"$outdir" ;;
      *)                print -u2 "x: '$f' format not supported" ;;
    esac
  done
}

# ── archive ───────────────────────────────────────────────────────────────────
function archive() {
  (( $# >= 2 )) || {
    echo "usage: a <output> [-C <srcdir>] [file ...]"
    echo "archive : tar.gz tar.bz2 tar.xz tar.zst tar zip 7z"
    echo "compress: gz bz2 xz zst  (single file, no -C)"
    return 0
  }
  local out=$1 srcdir=''; shift
  [[ $1 == -C ]] && { srcdir=$2; shift 2 }
  (( $# )) || set -- .
  [[ $out == /* ]] || out="$PWD/$out"
  local -a cdir=(); [[ -n $srcdir ]] && cdir=(-C "$srcdir")
  case $out in
    *.tar.gz|*.tgz)   tar czf "$out" "${cdir[@]}" "$@" ;;
    *.tar.bz2|*.tbz2) tar cjf "$out" "${cdir[@]}" "$@" ;;
    *.tar.xz)         tar cJf "$out" "${cdir[@]}" "$@" ;;
    *.tar.zst)        tar --use-compress-program=zstd -cf "$out" "${cdir[@]}" "$@" ;;
    *.tar)            tar cf  "$out" "${cdir[@]}" "$@" ;;
    *.zip)
      if [[ -n $srcdir ]]; then (cd "$srcdir" && zip -r "$out" "$@")
      else zip -r "$out" "$@"; fi ;;
    *.7z)
      if [[ -n $srcdir ]]; then (cd "$srcdir" && 7za a "$out" "$@")
      else 7za a "$out" "$@"; fi ;;
    *.gz)   gzip  -c "$1" > "$out" ;;
    *.bz2)  bzip2 -c "$1" > "$out" ;;
    *.xz)   xz    -c "$1" > "$out" ;;
    *.zst)  zstd     "$1" -o "$out" ;;
    *)      print -u2 "a: '$out' format not supported"; return 1 ;;
  esac
}

alias x=extract
alias a=archive
