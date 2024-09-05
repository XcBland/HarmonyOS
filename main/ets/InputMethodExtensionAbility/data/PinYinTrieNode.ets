import Logger from '../util/Logger';
import { getMainButtonGroupData, KeyButtonData } from './KeyButtonDataManager';

import { getAllPinyinList } from './PinyinListData';
import { Queue, Stack } from '@kit.ArkTS';

/**
 b ba bo bai bei bao ban ben bang beng bi bie biao bian bin bing bu
 p pa po pai pao pou pan pen pei pang peng pi pie piao pian pin ping pu
 m ma mo me mai mao mou man men mei mang meng mi mie miao miu mian min ming mu
 f fa fo fei fou fan fen fang feng fu
 d da de dai dei dao dou dan dang den deng di die diao diu dian ding dong du duan dun dui duo
 t ta te tai tao tou tan tang teng ti tie tiao tian ting tong tu tuan tun tui tuo
 n na nai nei nao ne nen nan nang neng ni nie niao niu nian nin niang ning nong nou nu nuan nun nuo nü nüe
 l la le lo lai lei lao lou lan lang leng li lia lie liao liu lian lin liang ling long lu luo lou luan lun lü lüe
 g ga ge gai gei gao gou gan gen gang geng gong gu gua guai guan guang gui guo
 k ka ke kai kao kou kan ken kang keng kong ku kua kuai kuan kuang kui kun kuo
 h ha he hai han hei hao hou hen hang heng hong hu hua huai huan hui huo hun huang
 j ji jia jie jiao jiu jian jin jiang jing jiong ju juan jun jue
 q qi qia qie qiao qiu qian qin qiang qing qiong qu quan qun que
 x xi xia xie xiao xiu xian xin xiang xing xiong xu xuan xun xue
 zh zha zhe zhi zhai zhao zhou zhan zhen zhang zheng zhong zhu zhua zhuai zhuan zhuang zhun zhui zhuo
 ch cha che chi chai chao chou chan chen chang cheng chong chu chua chuai chuan chuang chun chui chuo
 sh sha she shi shai shao shou shan shen shang sheng shu shua shuai shuan shuang shun shui shuo
 r re ri rao rou ran ren rang reng rong ru ruan run ruo
 z za ze zi zai zao zan zou zang zei zen zeng zong zu zuan zun zui zuo
 c ca ce ci cai cao cou can cen cang ceng cong cu cuan cun cui cuo
 s sa se si sai sao sou san sen sang seng song su suan sun sui suo
 y ya yao you yan yang yu ye yue yuan yi yin yun ying yo yong
 w wa wo wai wei wan wen wang weng wu
 *
 */
class TrieNode {
  children: Map<string, TrieNode>;
  isEndOfWord: boolean;

  constructor() {
    this.children = new Map();
    this.isEndOfWord = false;
  }
}

class Trie {
  root: TrieNode;

  constructor() {
    this.root = new TrieNode();
  }

  // 向字典树中添加单词
  addWord(word: string) {
    let node = this.root;
    for (const char of word) {
      if (!node.children.has(char)) {
        node.children.set(char, new TrieNode());
      }
      node = node.children.get(char)!;
    }
    node.isEndOfWord = true;
  }

  // 查询给定前缀后可能的单词
  getFollowingWords(prefix: string): string[] {
    let node = this.root;
    for (const char of prefix) {
      if (!node.children.has(char)) {
        return [];
      }
      node = node.children.get(char)!;
    }

    const words: string[] = [];
    this._collectWords(node, prefix, words);
    return words;
  }

  // 辅助函数：递归收集以node为根的路径上的所有单词
  private _collectWords(node: TrieNode, prefix: string, words: string[]): void {
    if (node.isEndOfWord) {
      words.push(prefix);
    }


    node.children.forEach((child, char) => {
      this._collectWords(child, prefix + char, words);
    });
  }
}


// ... 之前的 TrieNode 和 Trie 定义保持不变 ...
interface FollowingWordsAndSegments {
  words: string[];
  segments: string[];
}

class TrieWithSegmentation extends Trie {
  // 修改查询方法以支持分词功能
  getFollowingWordsAndSegments(prefix: string): FollowingWordsAndSegments {
    let node = this.root;
    for (const char of prefix) {
      if (!node.children.has(char)) {
        return { words: [], segments: [] }
      }
      ;
      node = node.children.get(char)!;
    }

    const words: string[] = [];
    const segments: string[] = []; // 用于存储分词结果

    this._collectWordsAndSegments(node, prefix, words, segments, true);
    return { words, segments };
  }

  // 新增方法，用于在输入新字符时提供智能提示和自动补全
  getNextSuggestions(currentPrefix: string, latestChar: string): string[] {
    // 确保当前前缀加上新字符是合法的
    const nextPrefix = currentPrefix + latestChar;
    if (this._isValidPinyin(nextPrefix)) {
      // 检查是否形成完整词汇
      if (this._isCompleteWord(nextPrefix)) {
        return [nextPrefix + ',']; // 完成词汇，添加分隔符
      } else {
        // 继续查找可能的后续拼音
        const possibleWordsAndSegments = this.getFollowingWordsAndSegments(nextPrefix);
        return possibleWordsAndSegments.words; // 返回可能的后续拼音作为提示
      }
    } else {
      // 如果加上新字符不合法，则不提供任何提示
      return [];
    }
  }

  //

  // 辅助函数：递归收集以node为根的路径上的所有单词及分词
  private _collectWordsAndSegments(node: TrieNode, prefix: string, words: string[], segments: string[],
    isFirstLevel = false) {
    if (isFirstLevel || node.isEndOfWord) {
      words.push(prefix);
      if (isFirstLevel) {
        segments.push(prefix);
      } // 首次进入或到达完整词时，记录为分词
    }

    node.children.forEach((child, char) => {
      this._collectWordsAndSegments(child, prefix + char, words, segments, false);
    });
  }

  // 辅助方法：检查给定的拼音片段是否完整（示例中简单判断）
  private _isCompleteWord(pinyin: string): boolean {
    // 实际应用中，这里应根据拼音到汉字的映射来判断
    // 例如，从预定义的合法词汇列表中查找
    let validWords = getAllPinyinList()
    return validWords.includes(pinyin); // 假设validWords包含所有合法单字和词组拼音
  }

  // 辅助方法：简单检查拼音是否合法（示例中未实现具体逻辑）
  private _isValidPinyin(pinyin: string): boolean {
    // 实现检查拼音格式是否合法的逻辑
    // 这里可以根据拼音规则进行简单正则表达式验证或其它逻辑
    return true; // 示例中默认返回true
  }
}

function onCharacterInput(currentInput: string, smartTrie: TrieWithSegmentation, newChar: string) {
  currentInput += newChar;
  const suggestions = smartTrie.getNextSuggestions(currentInput.slice(0, -1), newChar);
  console.log('当前输入:', currentInput, '，建议:', suggestions);
  // 根据suggestions更新UI或做其他处理
}

/**
 * 获取拼音树
 * @returns
 */
function getPinyinTrie() {
  const trieWithSeg = new TrieWithSegmentation();
  const pinyinList = getAllPinyinList();
  // 添加所有拼音到字典树
  pinyinList.forEach((pinyin) => {
    if (pinyin) {
      trieWithSeg.addWord(pinyin);
    }
  });
  return trieWithSeg;
}

// 使用示例
export function trieMain() {
  const trieWithSeg = getPinyinTrie();
  Logger.info(JSON.stringify(trieWithSeg))
  console.log(JSON.stringify(trieWithSeg))
  testInput('j', trieWithSeg)
  testInput('ji', trieWithSeg)
  testInput('jin', trieWithSeg)
}

/**
 * 智能选择按键输入的字符串
 * @param oldStr
 * @param btnData
 */
export function smartSelectChar(oldStr: string, btnData: KeyButtonData, pinyinStack: Queue<string>): string {
  let pinyinTrie = getPinyinTrie()
  let followingWordsAndSegments = pinyinTrie.getFollowingWordsAndSegments(oldStr)
  let words: string[] = followingWordsAndSegments.words
  let selectStr = ''
  if (btnData.fillStr) {
    // 按钮可输入的字符串
    let fillStrArray: string[] = Array.from(btnData.fillStr)
    let popValue = pinyinStack.pop()
    if (fillStrArray.indexOf(popValue) != -1) {
      btnData.selectStr = popValue
    } else {
      fillStrArray.forEach((fillStr) => {
        let newStr = oldStr + fillStr
        for (let i = 0; i < words.length; i++) {
          let word = words[i]
          if (word != oldStr && word.startsWith(newStr)) {
            btnData.selectStr = fillStr
            selectStr = fillStr
            break
          }
        }
      })
    }
    // 判断是否未选择字符, 未选择自动选择第一个
    if (btnData.selectStr == null) {
      btnData.selectStr = btnData.fillStr.charAt(0)
      selectStr = btnData.selectStr
    }
  }
  return selectStr
}

export function smartSelectCharOld(oldStr: string, btnData: KeyButtonData, pinyinStack: Queue<string>): string {
  let pinyinTrie = getPinyinTrie()
  let followingWordsAndSegments = pinyinTrie.getFollowingWordsAndSegments(oldStr)
  let words: string[] = followingWordsAndSegments.words
  let selectStr = ''
  if (btnData.fillStr) {
    // 按钮可输入的字符串
    let fillStrArray: string[] = Array.from(btnData.fillStr)
    fillStrArray.forEach((fillStr) => {
      let newStr = oldStr + fillStr
      for (let i = 0; i < words.length; i++) {
        let word = words[i]
        if (word != oldStr && word.startsWith(newStr)) {
          btnData.selectStr = fillStr
          selectStr = fillStr
          break
        }
      }
    })
    // 判断是否未选择字符, 未选择自动选择第一个
    if (btnData.selectStr == null) {
      btnData.selectStr = btnData.fillStr.charAt(0)
      selectStr = btnData.selectStr
    }
  }
  return selectStr
}


/**
 * 自动设置分词
 * @param oldStr 已输入的字符串
 * @param newStr 新输入的字符串，长度为1
 */
export function smartSetSeg(oldStr: string, newChar: string): string {
  let pinyinTrie = getPinyinTrie()
  let followingWordsAndSegments = pinyinTrie.getFollowingWordsAndSegments(oldStr)
  let words: string[] = followingWordsAndSegments.words
  let newStr = oldStr + newChar
  if (words.includes(newStr)) {
    return newStr
  } else {
    return oldStr + "'" + newChar
  }
}

export function smartSetNextStrSeg(oldStr: string, newChar: string): string {
  if (oldStr == '' || oldStr.endsWith("'")) {
    return newChar
  }
  let tempStr = oldStr.substring(oldStr.lastIndexOf("'") + 1, oldStr.length);
  let pinyinTrie = getPinyinTrie()
  let followingWordsAndSegments = pinyinTrie.getFollowingWordsAndSegments(tempStr)
  let words: string[] = followingWordsAndSegments.words
  let newStr = tempStr + newChar
  let matchWords: Array<string>
  if (words.includes(newStr)) {
    return newChar
  } else {
    return "'" + newChar
  }
}

export function getAllPossiblePinyin(keys: Array<KeyButtonData>): Array<string> {
  let resultList: string[] = []
  let pinyinTrie = getPinyinTrie()

  //
  let result: string[][] = [[]];


  let returnResult = result.map(combination => combination.join(''))
  return returnResult;
}

function testInput(str: string, trieWithSeg: TrieWithSegmentation) {
  // 查询输入'ai'之后可能的拼音和分词
  const input = str;
  const followingWordsAndSegments = trieWithSeg.getFollowingWordsAndSegments(input);
  const possibleWords = followingWordsAndSegments.words;
  const possibleSegments = followingWordsAndSegments.segments;

  console.log(`输入 '${input}' 后可能的拼音有：`, possibleWords);
  console.log(`输入 '${input}' 后可能的分词有：`, possibleSegments);
}

/**
 * 模拟用户输入
 */
export function imitateInput() {
  let newStr = smartSetSeg('ni', 'h')
  console.log('输入nih, 展示的结果为' + newStr)

  let newStr2 = smartSetSeg('ji', 'n')
  console.log('输入jin, 展示的结果为' + newStr2)

  let newStr3 = smartSetSeg('jin', 'g')
  console.log('输入jing, 展示的结果为' + newStr3)
}

/**
 * 模拟键盘输入
 */
export function imitateKeyboardInput() {
  let str = ''
  let inputArray: Array<number> = [8, 1, 4, 3, 2]
  // 拼音键盘数据
  let mainPinyin = getMainButtonGroupData()
  inputArray.forEach((value) => {
    let selectStr = smartSelectChar(str, mainPinyin[value], new Queue<string>())
    let newStr = smartSetSeg(str, selectStr)
    str = newStr
    // 选中的字符为
    console.log('选中的字符为:' + selectStr + ' , 输入界面应该展示: ' + str)
  })

}