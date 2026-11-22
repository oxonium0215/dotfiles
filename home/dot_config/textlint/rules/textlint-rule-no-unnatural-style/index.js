/**
 * @file textlint-rule-no-unnatural-style
 *
 * 以下の観点から自然で客観的な日本語文章を促進するtextlintルール:
 * 1. 【カタカナ語】
 *    - Error: 定義済みの不自然なビジネス/AIバズワード（アプローチ、ソリューション、シームレス、セキュア等）
 *    - Info: 平易な日本語への言い換えや辞書更新を促すレビュー候補（マネジメント、リソース、オペレーション等）
 * 2. 【括弧による補足の適切性・トートロジー】
 *    - 長さだけでなく、文末ぶら下がり理由節、完全文の埋め込み、思考の割り込み、1文中の多用を意味・構文的に判定
 *    - トートロジー的英訳併記（「組織（Organization）」などの直訳反復）の検出
 *    - 同一文書内での「用語（略称）」の重複再定義の検出
 *    - Warning/Error: 文末理由節ぶら下がり、述語文の埋め込み、1文中複数括弧、トートロジー的英単語併記
 *    - Info: 動詞節を含む補足のレビュー提案
 * 3. 【主観的・評価的表現】
 *    - Error: 確定的な誇張語（徹底的、完璧、圧倒的、劇的など）
 *    - Info: 主観的・相対的な評価語（非常に、極めて、最適な、容易に等）に対する客観的数値・根拠の検討提案
 */

const SEVERITY = {
    WARNING: 1,
    ERROR: 2,
    INFO: 3
};

// 確定的な不自然カタカナ語（Error）
const DEFAULT_KATAKANA_ERRORS = [
    { pattern: /(?<![ァ-ヶー])アプローチ(?:する|した|された|の|を|に)?(?![ァ-ヶー])/g, word: "アプローチ", suggestion: "「手法」「方法」「方針」「取り組み」など" },
    { pattern: /(?<![ァ-ヶー])ソリューション(?:の|を|に|で)?(?![ァ-ヶー])/g, word: "ソリューション", suggestion: "「解決策」「対策」「手段」など" },
    { pattern: /(?<![ァ-ヶー])レバレッジ(?:する|した|を効かせ)?(?![ァ-ヶー])/g, word: "レバレッジ", suggestion: "「活用」「利用」など" },
    { pattern: /(?<![ァ-ヶー])アライン(?:する|した|させる|メント)?(?![ァ-ヶー])/g, word: "アライン", suggestion: "「連携」「整合」「調整」「すり合わせ」など" },
    { pattern: /(?<![ァ-ヶー])シームレス(?:に|な)?(?![ァ-ヶー])/g, word: "シームレス", suggestion: "「円滑な」「途切れのない」「一貫した」など" },
    { pattern: /(?<![ァ-ヶー])プロアクティブ(?:に|な)?(?![ァ-ヶー])/g, word: "プロアクティブ", suggestion: "「能動的」「事前」「予防的」「積極的」など" },
    { pattern: /(?<![ァ-ヶー])ベストプラクティス(?![ァ-ヶー])/g, word: "ベストプラクティス", suggestion: "「推奨手順」「好ましい手法」「模範例」など" },
    { pattern: /(?<![ァ-ヶー])エコシステム(?![ァ-ヶー])/g, word: "エコシステム", suggestion: "「環境」「連携体系」など" },
    { pattern: /(?<![ァ-ヶー])エンハンス(?:する|した|された)?(?![ァ-ヶー])/g, word: "エンハンス", suggestion: "「強化」「向上」「拡張」など" },
    { pattern: /(?<![ァ-ヶー])ケイパビリティ(?![ァ-ヶー])/g, word: "ケイパビリティ", suggestion: "「機能」「対応能力」「性能」など" },
    { pattern: /(?<![ァ-ヶー])ディファレンス(?![ァ-ヶー])/g, word: "ディファレンス", suggestion: "「相違」「差異」「差分」など" },
    { pattern: /(?<![ァ-ヶー])オーケストレーション(?![ァ-ヶー])/g, word: "オーケストレーション", suggestion: "「統合管理」「一元管理」「自動統制」など" },
    { pattern: /(?<![ァ-ヶー])コンセンサス(?![ァ-ヶー])/g, word: "コンセンサス", suggestion: "「合意」「意見の一致」など" },
    { pattern: /(?<![ァ-ヶー])ワークアラウンド(?![ァ-ヶー])/g, word: "ワークアラウンド", suggestion: "「回避策」「代替手段」など" },
    { pattern: /(?<![ァ-ヶー])ファシリテート(?:する|した)?(?![ァ-ヶー])/g, word: "ファシリテート", suggestion: "「促進」「支援」「円滑化」など" },
    { pattern: /(?<![ァ-ヶー])フィージビリティ(?![ァ-ヶー])/g, word: "フィージビリティ", suggestion: "「実現可能性」「妥当性」など" },
    { pattern: /(?<![ァ-ヶー])セキュア(?:に|な)?(?![ァ-ヶー])/g, word: "セキュア", suggestion: "「安全な」「保護された」「暗号化された」など" }
];

// カタカナ語レビュー候補（Info: 手動見直し・辞書更新のきっかけとして情報提供）
const DEFAULT_KATAKANA_INFO_CANDIDATES = [
    { pattern: /(?<![ァ-ヶー])マネジメント(?![ァ-ヶー])/g, word: "マネジメント", suggestion: "「管理」「運用」" },
    { pattern: /(?<![ァ-ヶー])オペレーション(?![ァ-ヶー])/g, word: "オペレーション", suggestion: "「運用」「操作」「作業」" },
    { pattern: /(?<![ァ-ヶー])コンフィグレーション(?![ァ-ヶー])/g, word: "コンフィグレーション", suggestion: "「設定」「構成」" },
    { pattern: /(?<![ァ-ヶー])インテグレーション(?![ァ-ヶー])/g, word: "インテグレーション", suggestion: "「統合」「連携」" },
    { pattern: /(?<![ァ-ヶー])プライオリティ(?![ァ-ヶー])/g, word: "プライオリティ", suggestion: "「優先度」「優先順位」" },
    { pattern: /(?<![ァ-ヶー])アジリティ(?![ァ-ヶー])/g, word: "アジリティ", suggestion: "「俊敏性」「迅速性」" },
    { pattern: /(?<![ァ-ヶー])フェイルオーバー(?![ァ-ヶー])/g, word: "フェイルオーバー", suggestion: "「待機系切替」「自動切替」" }
];

// 確定的な主観的・誇張表現（Error）
const DEFAULT_SUBJECTIVE_ERRORS = [
    { pattern: /徹底(?:的(?:に|な|である|だ)?|し(?:た|て|ている|ています)?|の徹底|を徹底)/g, word: "徹底", suggestion: "客観的な事実や具体的な運用・設定・対応内容を記述してください。" },
    { pattern: /完璧(?:に|な|である|だ)?/g, word: "完璧", suggestion: "過度に絶対的な表現です。「十分な」「確実な」または具体的な検証結果を記述してください。" },
    { pattern: /圧倒的(?:に|な|である|だ)?/g, word: "圧倒的", suggestion: "感情的・誇張的な表現です。具体的な数値や比較結果を記述してください。" },
    { pattern: /劇的(?:に|な|である|だ)?/g, word: "劇的", suggestion: "誇張的な表現です。具体的な変化量や効果を記述してください。" },
    { pattern: /抜本的(?:に|な|である|だ)?/g, word: "抜本的", suggestion: "大げさな表現です。具体的にどの範囲を見直したかを記述してください。" },
    { pattern: /画期的(?:に|な|である|だ)?/g, word: "画期的", suggestion: "誇張的な表現です。具体的な新規性や改善点を記述してください。" },
    { pattern: /究極(?:の|的)?/g, word: "究極", suggestion: "誇張的な表現です。控えめで具体的な表現を検討してください。" },
    { pattern: /前代未聞|比類のない|唯一無二/g, word: "比類のない表現", suggestion: "誇張的な表現です。事実に基づいた表現にしてください。" },
    { pattern: /魔法のように/g, word: "魔法のように", suggestion: "非現実的な比喩です。具体的な仕組みを記述してください。" },
    { pattern: /言わずもがな|言うまでもなく/g, word: "言うまでもなく", suggestion: "主観的な前提表現です。記載が必要であれば直接述べてください。" }
];

// 相対的・主観的な評価語候補（Info: 数値や客観事実の提示を検討するためのヒント）
const DEFAULT_SUBJECTIVE_INFO_CANDIDATES = [
    { pattern: /(?<![ァ-ヶー\w])非常に/g, word: "非常に", suggestion: "具体的な程度や数値を明示できないか検討してください。" },
    { pattern: /(?<![ァ-ヶー\w])極めて/g, word: "極めて", suggestion: "主観を強める副詞です。客観的な指標への置き換えを検討してください。" },
    { pattern: /(?<![ァ-ヶー\w])著しく/g, word: "著しく", suggestion: "具体的な変化量や差分数値の記述を検討してください。" },
    { pattern: /(?<![ァ-ヶー\w])大いに/g, word: "大いに", suggestion: "客観的な表現への変更を検討してください。" },
    { pattern: /(?<![ァ-ヶー\w])容易に/g, word: "容易に", suggestion: "難易度は環境やスキルに依存します。具体的な手順を示すことを検討してください。" },
    { pattern: /(?<![ァ-ヶー\w])最適な/g, word: "最適な", suggestion: "何をもって最適とするかの基準や前提条件の明記を検討してください。" },
    { pattern: /(?<![ァ-ヶー\w])強力な/g, word: "強力な", suggestion: "抽象的な形容詞です。具体的な機能や性能を述べることを検討してください。" },
    { pattern: /(?<![ァ-ヶー\w])スムーズに/g, word: "スムーズに", suggestion: "具体的な処理時間や動作の流れを示すことを検討してください。" }
];

// 短い正当なステータスバッジ・注記
const VALID_STATUS_BADGES = new Set([
    "推奨", "任意", "必須", "非推奨", "参考", "デフォルト", "注意", "重要",
    "管理者用", "部員用", "自動", "手動"
]);

// 典型的なトートロジー的英訳パターン（直前の日本語をそのまま英単語で併記しただけの重複）
const TAUTOLOGICAL_TRANSLATION_REGEX = /([一-龠]{2,6})[（(]([A-Z][a-z]{2,20})[）)]/g;

module.exports = function(context, options = {}) {
    const { Syntax, RuleError, report } = context;

    const katakanaOpt = options.katakana || {};
    const parenthesesOpt = options.parentheses || {};
    const subjectiveOpt = options.subjective || {};
    const codeBlockOpt = options.codeBlock || {};

    const enableKatakana = katakanaOpt.enabled !== false;
    const enableParentheses = parenthesesOpt.enabled !== false;
    const enableSubjective = subjectiveOpt.enabled !== false;
    const enableCodeBlockSequentialComments = codeBlockOpt.noSequentialComments !== false;

    // Info レベルのサジェストを流すか（デフォルト: true）
    const showInfoSuggestions = options.showInfoSuggestions !== false;

    const katakanaErrors = [
        ...DEFAULT_KATAKANA_ERRORS,
        ...(katakanaOpt.extraWords || [])
    ];
    const katakanaInfoCandidates = [
        ...DEFAULT_KATAKANA_INFO_CANDIDATES,
        ...(katakanaOpt.extraInfoWords || [])
    ];
    const katakanaAllows = katakanaOpt.allows || [];

    const subjectiveErrors = [
        ...DEFAULT_SUBJECTIVE_ERRORS,
        ...(subjectiveOpt.extraWords || [])
    ];
    const subjectiveInfoCandidates = [
        ...DEFAULT_SUBJECTIVE_INFO_CANDIDATES,
        ...(subjectiveOpt.extraInfoWords || [])
    ];
    const subjectiveAllows = subjectiveOpt.allows || [];

    const ignoreTable = parenthesesOpt.ignoreTable !== false;
    const parenthesesAllows = parenthesesOpt.allows || [];
    const maxPerSentence = parenthesesOpt.maxPerSentence !== undefined ? parenthesesOpt.maxPerSentence : 1;

    const parenthesisRegex = /[（(]([^）)\n]+)[）)]/g;

    // 括弧内の述語・理由・条件節パターン
    const trailingReasonRegex = /(?:のため|により|によって|を防ぐため|を確保するため|が必要|を推奨)[。、]?$/;
    const embeddedClauseRegex = /(?:です|ます|である|だろ|だ|できる|できない|行います|構成します)[。、]?$/;
    const digressionRegex = /^(?:なお[、\s]|ただし[、\s]|※|と思われる)/;
    const hasVerbRegex = /(?:する|した|される|された|行う|防ぐ|できる|なる|ある|ない|れる|られる)/;

    // 単なる名詞・識別子・略称列挙・設定値であるか
    function isLegitimateAnnotation(content) {
        if (VALID_STATUS_BADGES.has(content)) return true;
        // コード値、英数略称（全て大文字の略称など）、URL、ポート番号、日付
        if (/^`[^`]+`$/.test(content) || /^[A-Z0-9_.\- /:+,#@]+$/.test(content)) return true;
        // 「例: xxx」「デフォルト: xxx」「ポート: 8080」形式
        if (/^(?:例|デフォルト|単位|ポート|プロトコル|参照|対象)[:：]/.test(content)) return true;

        // 述語や動詞を含まない名詞・ファイル名等の列挙
        if (!hasVerbRegex.test(content) && !digressionRegex.test(content) && !embeddedClauseRegex.test(content)) {
            return true;
        }
        return false;
    }

    let inTable = false;

    // 同一ドキュメント内での「用語（略称）」の出現記録
    const acronymOccurrences = new Map();

    return {
        [Syntax.Document]() {
            acronymOccurrences.clear();
        },
        [Syntax.Table]() {
            inTable = true;
        },
        [Syntax.Table + ":exit"]() {
            inTable = false;
        },

        // コードブロック内のコメントチェック（連番、括弧書き手順説明など）
        [Syntax.CodeBlock](node) {
            const code = node.value || "";
            const lines = code.split("\n");
            let offset = 0;

            for (const line of lines) {
                if (enableCodeBlockSequentialComments) {
                    const match = line.match(/^\s*(?:#|\/\/|\/\*|--|<!--)\s*((?:(?:\d+[\.:\)]|Step\s*\d+|手順\s*\d+|[①-⑩]|[（(]\d+[）)]))\s*.*)/i);
                    if (match) {
                        report(node, {
                            message: `コードブロック内のコメントに連番（「${match[0].trim()}」）が付けられています。手順は Markdown の番号付きリストや見出しとして記述し、各手順の下にコードブロックを配置するか、連番を外した簡潔な説明コメントにしてください。`,
                            index: offset + line.indexOf(match[0].trim()),
                            severity: SEVERITY.WARNING
                        });
                    }
                }

                // コードブロック内のコメントに括弧書き手順や補足、あるいは句点付き体言止めが含まれる場合
                const commentMatch = line.match(/^\s*(?:#|\/\/|\/\*|--|<!--)\s*(.*)/);
                if (commentMatch) {
                    const commentBody = commentMatch[1].trim();
                    const bracketMatch = commentBody.match(/^[（(][^）)\n]+[）)]/);
                    if (bracketMatch) {
                        report(node, {
                            message: `コードブロック内のコメントに括弧書き（「${bracketMatch[0]}」）が含まれています。実行コマンドと関係のない手順説明や補足は、コードブロックの外に Markdown の地の文や注意書きブロック（> [!TIP] 等）として記述してください。`,
                            index: offset + line.indexOf(bracketMatch[0]),
                            severity: SEVERITY.WARNING
                        });
                    }

                    const taigendomeMatch = commentBody.match(/(?:[ぁ-んァ-ヶ一-龠A-Za-z0-9])(?:必須|推奨|完了|可能|必要|有効|無効)[。]/);
                    if (taigendomeMatch) {
                        report(node, {
                            message: `コメント末尾が「${taigendomeMatch[0]}」のように体言止め＋句点になっています。文脈に合わせて自然な述語（「〜が必要です」「〜を推奨します」など）にするか、コードブロック外の地の文として記述してください。`,
                            index: offset + line.indexOf(taigendomeMatch[0]),
                            severity: SEVERITY.WARNING
                        });
                    }
                }

                offset += line.length + 1;
            }
        },

        // 文単位での括弧多用チェック
        [Syntax.Paragraph](node) {
            if (!enableParentheses || (inTable && ignoreTable)) return;

            const raw = node.raw || "";
            const sentences = raw.split(/。/);
            let searchOffset = 0;

            for (const sentence of sentences) {
                if (!sentence) continue;
                parenthesisRegex.lastIndex = 0;
                let pMatch;
                let explanatoryCount = 0;
                const explanatoryMatches = [];

                while ((pMatch = parenthesisRegex.exec(sentence)) !== null) {
                    const content = pMatch[1].trim();
                    if (!isLegitimateAnnotation(content)) {
                        explanatoryCount++;
                        explanatoryMatches.push({
                            content: content,
                            index: searchOffset + pMatch.index
                        });
                    }
                }

                if (explanatoryCount > maxPerSentence) {
                    for (let i = 1; i < explanatoryMatches.length; i++) {
                        const m = explanatoryMatches[i];
                        report(node, {
                            message: `1文中に複数の括弧注記が含まれています（${explanatoryCount}箇所: 「${m.content}」など）。文の主述構造が乱れるため、文の分割や地の文への統合を検討してください。`,
                            index: m.index,
                            severity: SEVERITY.WARNING
                        });
                    }
                }

                searchOffset += sentence.length + 1;
            }
        },

        [Syntax.Str](node) {
            const text = node.value;

            // 1. カタカナ語のチェック
            if (enableKatakana) {
                // (a) Error: 不自然なバズワード
                for (const item of katakanaErrors) {
                    item.pattern.lastIndex = 0;
                    let match;
                    while ((match = item.pattern.exec(text)) !== null) {
                        const matchedText = match[0];
                        const isAllowed = katakanaAllows.some(a => (typeof a === "string" ? matchedText.includes(a) : a.test(matchedText)));
                        if (isAllowed) continue;

                        report(node, {
                            message: `不自然・過剰に使われがちなカタカナ語「${matchedText}」が検出されました。より自然で平易な日本語（${item.suggestion}）への言い換えを検討してください。`,
                            index: match.index,
                            severity: SEVERITY.ERROR
                        });
                    }
                }

                // (b) Info: 手動レビュー・辞書更新のための候補提示
                if (showInfoSuggestions) {
                    for (const item of katakanaInfoCandidates) {
                        item.pattern.lastIndex = 0;
                        let match;
                        while ((match = item.pattern.exec(text)) !== null) {
                            const matchedText = match[0];
                            const isAllowed = katakanaAllows.some(a => (typeof a === "string" ? matchedText.includes(a) : a.test(matchedText)));
                            if (isAllowed) continue;

                            report(node, {
                                message: `【カタカナ語レビュー】「${matchedText}」が使用されています。平易な日本語（${item.suggestion}）への言い換え、または用語集への登録を検討してください。`,
                                index: match.index,
                                severity: SEVERITY.INFO
                            });
                        }
                    }
                }
            }

            // 2. 主観的・誇張表現のチェック
            if (enableSubjective) {
                // (a) Error: 確定的な誇張語
                for (const item of subjectiveErrors) {
                    item.pattern.lastIndex = 0;
                    let match;
                    while ((match = item.pattern.exec(text)) !== null) {
                        const matchedText = match[0];
                        const isAllowed = subjectiveAllows.some(a => (typeof a === "string" ? matchedText.includes(a) : a.test(matchedText)));
                        if (isAllowed) continue;

                        report(node, {
                            message: `主観的または誇張的な単語「${matchedText}」が検出されました。${item.suggestion}`,
                            index: match.index,
                            severity: SEVERITY.ERROR
                        });
                    }
                }

                // (b) Info: 主観・評価的表現のレビューヒント
                if (showInfoSuggestions) {
                    for (const item of subjectiveInfoCandidates) {
                        item.pattern.lastIndex = 0;
                        let match;
                        while ((match = item.pattern.exec(text)) !== null) {
                            const matchedText = match[0];
                            const isAllowed = subjectiveAllows.some(a => (typeof a === "string" ? matchedText.includes(a) : a.test(matchedText)));
                            if (isAllowed) continue;

                            report(node, {
                                message: `【主観・評価表現レビュー】「${matchedText}」は主観的・相対的な評価語です。${item.suggestion}`,
                                index: match.index,
                                severity: SEVERITY.INFO
                            });
                        }
                    }
                }
            }

            // 3. 括弧による補足の適切性・トートロジーチェック
            if (enableParentheses && (!inTable || !ignoreTable)) {
                // (A) トートロジー的英単語併記の検出（例: 「組織（Organization）」など直前の日本語をそのまま英訳しただけのもの）
                TAUTOLOGICAL_TRANSLATION_REGEX.lastIndex = 0;
                let tMatch;
                while ((tMatch = TAUTOLOGICAL_TRANSLATION_REGEX.exec(text)) !== null) {
                    const jp = tMatch[1];
                    const en = tMatch[2];
                    report(node, {
                        message: `「${jp}（${en}）」のように直前の日本語に対して英単語を括弧で添える表記は、同義語の重複（トートロジー）の印象を与える可能性があります。「${jp}」または「${en}」のいずれかに統一するか、括弧を取り除くことを検討してください。`,
                        index: tMatch.index,
                        severity: SEVERITY.WARNING
                    });
                }

                // (B) 同一文書内での「用語（略称）」の重複再定義チェック（例: 「二要素認証（TOTP）」が2回目以降も併記される）
                const acronymPairRegex = /(?:[一-龠ぁ-んァ-ヶA-Za-z0-9]+)?[（(]([A-Z0-9]{2,6})[）)]/g;
                let aMatch;
                while ((aMatch = acronymPairRegex.exec(text)) !== null) {
                    const full = aMatch[0];
                    const acronym = aMatch[1];
                    if (VALID_STATUS_BADGES.has(acronym) || /^(?:GET|POST|PUT|DELETE|PATCH)$/.test(acronym)) continue;
                    const count = (acronymOccurrences.get(acronym) || 0) + 1;
                    acronymOccurrences.set(acronym, count);

                    if (count > 1) {
                        report(node, {
                            message: `略称「${acronym}」の括弧定義（「${full}」）が同一文書内で重複しています。略称は初出時に一度定義すれば十分です。2回目以降は括弧を付けずに「${acronym}」と直接記述してください。`,
                            index: aMatch.index,
                            severity: SEVERITY.WARNING
                        });
                    }
                }

                parenthesisRegex.lastIndex = 0;
                let match;

                while ((match = parenthesisRegex.exec(text)) !== null) {
                    const content = match[1].trim();
                    const fullMatch = match[0];
                    const matchIndex = match.index;

                    const isAllowed = parenthesesAllows.some(a => (typeof a === "string" ? content.includes(a) : a.test(content)));
                    if (isAllowed) continue;

                    // 正当な略称・名詞列挙・ラベルは除外
                    if (isLegitimateAnnotation(content)) continue;

                    const afterMatch = text.slice(matchIndex + fullMatch.length, matchIndex + fullMatch.length + 2);
                    const isAtEndOfSentence = afterMatch.startsWith("。") || afterMatch.startsWith("\n") || afterMatch === "";

                    // (a) 文末ぶら下がり理由・補足
                    if (isAtEndOfSentence && trailingReasonRegex.test(content)) {
                        report(node, {
                            message: `文末に括弧による理由・補足（「${content}」）が配置されています。文頭に理由を置くか（例: 『〜のため、…』）、文を分けて記述することを検討してください。`,
                            index: matchIndex,
                            severity: SEVERITY.WARNING
                        });
                    }
                    // (b) 完全文・述語節の埋め込み
                    else if (embeddedClauseRegex.test(content)) {
                        report(node, {
                            message: `括弧内に文（述語節: 「${content}」）が埋め込まれています。括弧による過度な補足を避け、地の文として記述するか独立した文に分けてください。`,
                            index: matchIndex,
                            severity: SEVERITY.WARNING
                        });
                    }
                    // (c) 思考の割り込み・注記の割り込み
                    else if (digressionRegex.test(content)) {
                        report(node, {
                            message: `文中に条件や注記節（「${content}」）が括弧で割り込んでいます。注意書きブロックにするか、独立した文として明記することを検討してください。`,
                            index: matchIndex,
                            severity: SEVERITY.WARNING
                        });
                    }
                    // (d) Info: 動詞節を含むその他の補足（適切性を手動で判断するための情報提供）
                    else if (showInfoSuggestions && hasVerbRegex.test(content)) {
                        report(node, {
                            message: `【括弧補足レビュー】括弧内に動作や条件を含む補足（「${content}」）があります。可読性の観点から、地の文への組み込みや文の分割が可能か確認してください。`,
                            index: matchIndex,
                            severity: SEVERITY.INFO
                        });
                    }
                }
            }

            // 4. 不自然な体言止め（句点付き体言止め）のチェック
            if (!inTable || !ignoreTable) {
                const abruptNounPeriodRegex = /(?:[ぁ-んァ-ヶ一-龠A-Za-z0-9])(?:必須|推奨|完了|可能|必要|有効|無効)[。]/g;
                let npMatch;
                while ((npMatch = abruptNounPeriodRegex.exec(text)) !== null) {
                    const matched = npMatch[0];
                    report(node, {
                        message: `文末が「${matched}」のように体言止め＋句点になっています。文脈に合わせて自然な述語（「〜が必要です」「〜を推奨します」「〜が可能です」など）で結ぶか、箇条書きのラベルとして整理してください。`,
                        index: npMatch.index,
                        severity: SEVERITY.WARNING
                    });
                }
            }
        }
    };
};
