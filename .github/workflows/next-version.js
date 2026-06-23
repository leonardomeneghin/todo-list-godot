#!/usr/bin/env node
/**
 * Calcula a próxima tag de versão no formato vMAJOR.MINOR.PATCH onde:
 *   - MAJOR vem da variável de ambiente GODOT_MAJOR (ex: GODOT_VERSION="4.3" -> MAJOR=4)
 *   - MINOR/PATCH são calculados a partir dos commits (Conventional Commits)
 *     desde a última tag QUE TENHA O MESMO MAJOR.
 *
 * Regras de bump (iguais ao commit-analyzer do semantic-release):
 *   - feat / perf / refactor / revert  -> minor (a menos que seja BREAKING, tratado abaixo)
 *   - fix                              -> patch
 *   - BREAKING CHANGE: / "feat!:" etc. -> NÃO sobe o major (major é travado pelo Godot),
 *                                          mas ainda soma como minor pra não passar batido.
 *
 * Se o major do Godot mudou desde a última tag (ex: 4 -> 5), a versão reinicia
 * para MAJOR.0.0, ignorando o histórico de commits anteriores.
 *
 * Uso:
 *   GODOT_MAJOR=4 node next-version.js
 *
 * Saída (stdout): apenas a nova tag, ex: v4.3.0
 * Se não houver nenhuma mudança que justifique release, sai com código 1 e nada no stdout.
 */

const { execSync } = require("node:child_process");

function sh(cmd) {
  return execSync(cmd, { encoding: "utf8" }).trim();
}

function getGodotMajor() {
  const major = process.env.GODOT_MAJOR;
  if (!major || !/^\d+$/.test(major)) {
    console.error(`GODOT_MAJOR inválido ou ausente: "${major}". Defina GODOT_MAJOR=4 por exemplo.`);
    process.exit(2);
  }
  return parseInt(major, 10);
}

function getLastTagForMajor(major) {
  // Lista todas as tags vMAJOR.*.* ordenadas por versão, pega a mais recente
  let tags = [];
  try {
    tags = sh(`git tag --list "v${major}.*.*" --sort=-v:refname`)
      .split("\n")
      .filter(Boolean);
  } catch {
    tags = [];
  }
  return tags[0] || null;
}

function getLastTagAnyMajor() {
  let tags = [];
  try {
    tags = sh(`git tag --list "v*.*.*" --sort=-v:refname`)
      .split("\n")
      .filter(Boolean);
  } catch {
    tags = [];
  }
  return tags[0] || null;
}

function parseTag(tag) {
  const m = /^v(\d+)\.(\d+)\.(\d+)$/.exec(tag);
  if (!m) return null;
  return { major: parseInt(m[1], 10), minor: parseInt(m[2], 10), patch: parseInt(m[3], 10) };
}

function getCommitsSince(tag) {
  const range = tag ? `${tag}..HEAD` : "HEAD";
  let log = "";
  try {
    log = sh(`git log ${range} --pretty=format:%s%n%b%n---COMMIT-END---`);
  } catch {
    log = "";
  }
  return log
    .split("---COMMIT-END---")
    .map((c) => c.trim())
    .filter(Boolean);
}

function classifyBump(commits) {
  let hasMinor = false;
  let hasPatch = false;
  let hasBreaking = false;

  const minorTypes = /^(feat|perf|refactor|revert)(\(.+\))?!?:/i;
  const patchTypes = /^(fix)(\(.+\))?!?:/i;

  for (const commit of commits) {
    const firstLine = commit.split("\n")[0];

    if (/BREAKING CHANGE:/i.test(commit) || /^(\w+)(\(.+\))?!:/.test(firstLine)) {
      hasBreaking = true;
    }
    if (minorTypes.test(firstLine)) hasMinor = true;
    if (patchTypes.test(firstLine)) hasPatch = true;
  }

  if (hasBreaking || hasMinor) return "minor";
  if (hasPatch) return "patch";
  return null; // nada que justifique release
}

function main() {
  const godotMajor = getGodotMajor();
  const lastTagForMajor = getLastTagForMajor(godotMajor);
  const lastTagAnyMajor = getLastTagAnyMajor();

  // Caso 1: já existe tag para esse major do Godot -> incrementa normalmente
  if (lastTagForMajor) {
    const parsed = parseTag(lastTagForMajor);
    const commits = getCommitsSince(lastTagForMajor);
    const bump = classifyBump(commits);

    if (!bump) {
      console.error(`Nenhum commit relevante desde ${lastTagForMajor}. Nenhuma release necessária.`);
      process.exit(1);
    }

    const next =
      bump === "minor"
        ? `v${parsed.major}.${parsed.minor + 1}.0`
        : `v${parsed.major}.${parsed.minor}.${parsed.patch + 1}`;

    console.log(next);
    return;
  }

  // Caso 2: não existe tag para esse major ainda (major do Godot mudou, ou é a primeira release)
  // Sempre reinicia em MAJOR.0.0 -- precisa de pelo menos 1 commit desde a última tag de qualquer major
  const commits = getCommitsSince(lastTagAnyMajor);
  if (lastTagAnyMajor && commits.length === 0) {
    console.error(`Nenhum commit novo desde ${lastTagAnyMajor}. Nenhuma release necessária.`);
    process.exit(1);
  }

  console.log(`v${godotMajor}.0.0`);
}

main();
