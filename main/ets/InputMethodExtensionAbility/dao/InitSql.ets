/**
 * 获取创建词库的建表语句语句
 * @returns
 */
export function getInitWordSql(): string[] {
  return [

    `CREATE TABLE pinyin_segments (
    segment_id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER,
  segment TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  FOREIGN KEY(word_id) REFERENCES "words_all"(word_id)
  );`,


    `
  CREATE TABLE word_rep (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  create_time INTEGER
  );
  `,

    `CREATE TABLE "words"(
    word_id INTEGER PRIMARY KEY AUTOINCREMENT,
  word TEXT,
  pinyin TEXT,
  is_common INTEGER,
  frequency INTEGER,
  rep_id INTEGER,
  tone INTEGER,
  group_pin TEXT
  );`
  ]

}

function getWordRepData(): string[] {
  return []
}