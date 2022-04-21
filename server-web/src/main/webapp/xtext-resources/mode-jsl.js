define(["ace/lib/oop", "ace/mode/text", "ace/mode/text_highlight_rules"], function(oop, mText, mTextHighlightRules) {
	var HighlightRules = function() {
        var keywords = "var|construct|destruct|save|load|if|else|for|in|while|validate|unset|delete|return|break|continue|new|implies|or|xor|and|div|mod|not|throw|try|catch|self|actor|username|principal|boolean|binary|string|numeric|date|time|timestamp|mapped|as|abstract|extends|model|import|annotate|diagram|entity|transfer|type|union|error|enum|authorize|stage|table|column|layout|constraint|field|identifier|derived|relation|action|static|throws|group|package|widget|void|override|onerror|class|horizontal|vertical|hide\\-attributes|hide\\-actions|hide-relations|expression|opposite|opposite\\-add|read\\-only|max\\-length|mime\\-types|max\\-file\\-size|regex|precision|required|cascade|scale|frame|label|icon|stretch\\-horizontal|stretch\\-vertical|stretch\\-both|width|height";
		this.$rules = {
			"start": [
				{token: "comment", regex: "\\/\\/.*$"},
				{token: "comment", regex: "\\/\\*", next : "comment"},
				{token: "string", regex: '["](?:(?:\\\\.)|(?:[^"\\\\]))*?["]'},
				{token: "constant.numeric", regex: "[+-]?\\d+(?:(?:\\.\\d*)?(?:[eE][+-]?\\d+)?)?\\b"},
				{token: "keyword", regex: "\\b(?:" + keywords + ")\\b"}
			],
			"comment": [
				{token: "comment", regex: ".*?\\*\\/", next : "start"},
				{token: "comment", regex: ".+"}
			]
		};
	};
	oop.inherits(HighlightRules, mTextHighlightRules.TextHighlightRules);
	
	var Mode = function() {
		this.HighlightRules = HighlightRules;
	};
	oop.inherits(Mode, mText.Mode);
	Mode.prototype.$id = "xtext/jsl";
	Mode.prototype.getCompletions = function(state, session, pos, prefix) {
		return [];
	}
	
	return {
		Mode: Mode
	};
});