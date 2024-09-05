export class ColumnInfo {
  name: string;
  entityType: string;

  constructor(name: string, entityType: string) {
    this.name = name
    this.entityType = entityType;
  }
}

export enum ColumnType {
  STRING, LONG, TEXT, INTEGER
}