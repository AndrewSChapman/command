module entity.requestinfo;

import vibe.utils.dictionarylist;

alias HeaderDictionary = DictionaryList!(string,false,12L,false);
alias ParamsDictionary = DictionaryList!(string,true,16L,false);

struct RequestInfo {
	HeaderDictionary headers;
	ParamsDictionary getParams;
	string userAgent;
	string ipAddress;
	string tokenCode;

	// Populated by checkToken method
	string prefix;
	ulong usrId;
    uint usrType;
}