namespace EmojiData {

  export interface IEmojiRep {
    id: number;
    name: string;
  }

  export interface IEmoji {
    character: string
    //id:number
    //repId:number
    //keywords:string
  }

  export interface IEmojiGroup {
    id: number;
    emojiList: IEmoji[]
  }

  /**
   * 获取所有的表情分类
   * @returns
   */
  export function getEmojiRep(): IEmojiRep[] {
    return [{ id: 1, "name": "笑脸和情感" }, { "id": 2, "name": "人类和身体" }, { "id": 3, "name": "动物和自然" },
      { "id": 4, "name": "食物和饮料" }, { "id": 5, "name": "旅行和地点" }, { "id": 6, "name": "活动" },
      { "id": 7, "name": "物品" }, { "id": 8, "name": "符号" }, { "id": 9, "name": "旗帜" }];
  }

  export function getEmojiList(): IEmoji[] {
    return [{ "character": "😀" }, { "character": "😃" }, { "character": "😄" }, { "character": "😁" },
      { "character": "😆" }, { "character": "😅" }, { "character": "😂" }, { "character": "🤣" }, { "character": "☺" },
      { "character": "😊" }, { "character": "😇" }, { "character": "🙂" }, { "character": "🙃" }, { "character": "😉" },
      { "character": "😌" }, { "character": "😍" }, { "character": "🥰" }, { "character": "😘" }, { "character": "😗" },
      { "character": "😙" }, { "character": "😚" }, { "character": "😋" }, { "character": "😛" }, { "character": "😝" },
      { "character": "😜" }, { "character": "🤪" }, { "character": "🤨" }, { "character": "🧐" }, { "character": "🤓" },
      { "character": "😎" }, { "character": "🤩" }, { "character": "🥳" }, { "character": "😏" }, { "character": "😒" },
      { "character": "😞" }, { "character": "😔" }, { "character": "😟" }, { "character": "😕" }, { "character": "🙁" },
      { "character": "☹" }, { "character": "😣" }, { "character": "😖" }, { "character": "😫" }, { "character": "😩" },
      { "character": "🥺" }, { "character": "😢" }, { "character": "😭" }, { "character": "😤" }, { "character": "😠" },
      { "character": "😡" }, { "character": "🤬" }, { "character": "🤯" }, { "character": "😳" }, { "character": "🥵" },
      { "character": "🥶" }, { "character": "😱" }, { "character": "😨" }, { "character": "😰" }, { "character": "😥" },
      { "character": "😓" }, { "character": "🤗" }, { "character": "🤔" }, { "character": "🤭" }, { "character": "🤫" },
      { "character": "🤥" }, { "character": "😶" }, { "character": "😐" }, { "character": "😑" }, { "character": "😬" },
      { "character": "🙄" }, { "character": "😯" }, { "character": "😦" }, { "character": "😧" }, { "character": "😮" },
      { "character": "😲" }, { "character": "😴" }, { "character": "🤤" }, { "character": "😪" }, { "character": "😵" },
      { "character": "🤐" }, { "character": "🥴" }, { "character": "🤢" }, { "character": "🤮" }, { "character": "🤧" },
      { "character": "😷" }, { "character": "🤒" }, { "character": "🤕" }, { "character": "🤑" }, { "character": "🤠" },
      { "character": "😈" }, { "character": "👿" }, { "character": "👹" }, { "character": "👺" }, { "character": "🤡" },
      { "character": "💩" }, { "character": "👻" }, { "character": "💀" }, { "character": "☠" }, { "character": "👽" },
      { "character": "👾" }, { "character": "🤖" }, { "character": "🎃" }, { "character": "😺" }, { "character": "😸" },
      { "character": "😹" }, { "character": "😻" }, { "character": "😼" }, { "character": "😽" }, { "character": "🙀" },
      { "character": "😿" }, { "character": "😾" }];
  }

}

export default EmojiData