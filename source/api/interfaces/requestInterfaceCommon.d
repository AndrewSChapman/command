module api.requestinterface.common;

public import vibe.vibe;
public import vibe.utils.dictionarylist;
public import entity.all;

alias HeaderDictionary = DictionaryList!(string,false,12L,false);

static RequestInfo getRequestInfo(HTTPServerRequest req, HTTPServerResponse res)
{
	RequestInfo requestInfo;
	requestInfo.headers = req.headers;
	requestInfo.getParams = req.query;
	requestInfo.ipAddress = req.clientAddress.toAddressString();
	requestInfo.userAgent = requestInfo.headers.get("User-Agent", "");
	requestInfo.tokenCode = requestInfo.headers.get("Token-Code", "");
	
	return requestInfo;
}