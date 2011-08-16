From: Pawan Singh <psingh@silver-peak.com>
Subject: A question about MTUs and TCP stack
Date: Tue, 16 Aug 2011 11:33:40 -0700
Message-ID: <A55791AD2520D54CA92150D16630D03B36116A5B@VA3DIAXVS1F1.RED001.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: base64
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:26196
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752688Ab1HPSdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 14:33:50 -0400
Received: from mail163-ch1 (localhost.localdomain [127.0.0.1])	by
 mail163-ch1-R.bigfish.com (Postfix) with ESMTP id 1DDBBFE82F1	for
 <netdev@vger.kernel.org>; Tue, 16 Aug 2011 18:33:49 +0000 (UTC)
Received: from CH1EHSMHS013.bigfish.com (snatpool1.int.messaging.microsoft.com
 [10.43.68.246])	by mail163-ch1.bigfish.com (Postfix) with ESMTP id
 53E61DB8066	for <netdev@vger.kernel.org>; Tue, 16 Aug 2011 18:33:48 +0000
 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkNCg0KSSBhbSBwb3N0aW5nIHRoaXMgcXVlc3Rpb24gdG8gIm5ldGRldiIgbWFpbGluZyBsaXN0
IGJlY2F1c2UgSSBjb3VsZCBubyBsb25nZXIgZmluZCAibGludXgtbmV0IiBtYWlsaW5nIGxpc3Qu
DQoNCkkgZmluZCB0aGF0IHRoZSBMaW51eCBUQ1Agc3RhY2sgY29uc3VtZXMgaHVnZSBhbW91bnQg
b2YgQ1BVIGlmIHRoZSBNVFUgb2YgYW4gaW50ZXJmYWNlIGlzIHNldCB0byAyNDAwIGFuZCBpdCBp
cyByZWNlaXZpbmcgMTAwMCBieXRlIEV0aGVybmV0IHBhY2tldHMuIE9uIHRoZSBvdGhlciBoYW5k
LCBpZiB0aGUgTVRVIGlzIHNldCB0byAxNTAwLCB0aGUgQ1BVIGNvbnN1bXB0aW9uIGlzIHJlZHVj
ZWQgZHJhc3RpY2FsbHkuIEluY3JlYXNlZCBDUFUgdXNhZ2UgY2F1c2VzIG5ldHdvcmsgdGhyb3Vn
aHB1dCB0byBkcm9wIGNvbnNpZGVyYWJseSAoZnJvbSA4MDAtOTAwIE1icHMgdG8gMjAwIE1icHMp
LiBNeSBrZXJuZWwgdmVyc2lvbiBpcyBmZWRvcmEgY29yZSA2IGFuZCB3ZSBhcmUgdXNpbmcgMSBH
aWcgTklDcyAoSW50ZWwgODI1NDZHQiBhbmQgQnJvYWRjb20gTmV0WHRyZW1lIEJDTTU3MjEpOg0K
DQpMaW51eCBoZTc3MDAtdGcgMi42LjIyLjE0LTcyLmZjNiAjMSBTTVAgV2VkIE5vdiAyMSAxNDox
MDoyNSBFU1QgMjAwNyB4ODZfNjQgeDg2XzY0IHg4Nl82NCBHTlUvTGludXgNCg0KSSBkbyBub3Qg
a25vdyB0aGUgVENQIGJ1ZmZlciBtYW5hZ2VtZW50IGludGVybmFscyBhbmQgaG93IHRoZXkgYXJl
IGFmZmVjdGVkIGJ5IE1UVS4gSXMgdGhlcmUgc29tZSBGQVEvaW5mb3JtYXRpb24gb25saW5lIG9y
IGRvIEkgaGF2ZSB0byBvcGVuIHVwIHRoZSBzb3VyY2UgY29kZSBhbmQgdHJ5IHRvIGlkZW50aWZ5
IHRoZSBzb3VyY2Ugb2YgdGhlIHByb2JsZW0uIEkgZ3Vlc3MgSSBjYW4gYWxzbyB0cnkgbmV3ZXIg
dmVyc2lvbnMgb2YgdGhlIGtlcm5lbCBhbmQgc2VlIGlmIHRoZSBpc3N1ZSBoYXMgYmVlbiByZXNv
bHZlZC4NCg0KLVBhd2FuDQoNCg==

