From: "Barak Witkowski" <barak@broadcom.com>
Subject: RE: [PATCH net-next 4/4 v2] bnx2x, cnic: support DRV_INFO upon
 FW request
Date: Sun, 11 Dec 2011 05:47:55 -0800
Message-ID: <B5B11E37A838B441A7C7485B190FA193D194822030@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1323157945-28333-1-git-send-email-mchan@broadcom.com>
 <1323157945-28333-2-git-send-email-mchan@broadcom.com>
 <1323157945-28333-3-git-send-email-mchan@broadcom.com>
 <1323157945-28333-4-git-send-email-mchan@broadcom.com>
 <1323158294.1762.4.camel@joe2Laptop>
 <0E685F8B314BFB42AE2422915B7BDCC3066290@IRVEXCHMB07.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Michael Chan" <mchan@broadcom.com>,
	"'Joe Perches'" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4554 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550Ab1LKNsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Dec 2011 08:48:08 -0500
In-Reply-To: <0E685F8B314BFB42AE2422915B7BDCC3066290@IRVEXCHMB07.corp.ad.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TWljaGFlbCBDaGFuIHdyb3RlOg0KPiBKb2UgUGVyY2hlcyB3cm90ZToNCj4gPg0KPiA+ID4gKwkj
ZGVmaW5lIERSVl9GTEFHU19DQVBBQklMSVRJRVNfTE9BREVEX0wyICAgICAgICAweDAwMDAwMDAy
DQo+ID4gPiArCSNkZWZpbmUgRFJWX0ZMQUdTX0NBUEFCSUxJVElFU19MT0FERURfRkNPRSAgICAg
IDB4MDAwMDAwMDQNCj4gPiA+ICsJI2RlZmluZSBEUlZfRkxBR1NfQ0FQQUJJTElUSUVTX0xPQURF
RF9JU0NTSSAgICAgMHgwMDAwMDAwOA0KPiA+DQo+ID4gSSB0aGluayB0aGUgI2RlZmluZXMgc2hv
dWxkIGJlIGxlZnQgYWxpZ25lZC4NCj4gPg0KPiANCj4gSSdsbCBmaXggdXAgc29tZSBvZiB0aGVz
ZSwgYnV0IG1hbnkgI2RlZmluZXMgaW4gdGhpcyBmaWxlIGFyZSBub3QNCj4gc3RhcnRpbmcgYXQg
dGhlIGxlZnQgbWFyZ2luLiAgIEVpbG9uIHdpbGwgZml4IHRob3NlIHVwIHdpdGggYSBzZXBhcmF0
ZQ0KPiBwYXRjaCBsYXRlci4NCg0KSW4gdGhhdCBhcmVhIG9mIHRoZSBmaWxlIGFsbCBvZiB0aGUg
I2RlZmluZXMgcmVsYXRlZCB0byBzcGVjaWZpYyBmaWVsZCBhcmUgbm90IGxlZnQgYWxpZ25lZCwg
YnV0IGFsaWduZWQgdG8gdGhlIGZpZWxkIGRlZmluaXRpb24gdGhleSByZWZlciB0by4NCldlIGxv
b2tlZCBpbnRvIGl0IGFuZCB0cmllZCBsZWZ0IGFsaWduaW5nIGFsbCBvZiB0aG9zZSBkZWZpbml0
aW9ucyBhbmQgZm91bmQgaXQgbGVzcyByZWFkYWJsZSwgYXMgdGhpcyBwYXJ0IGNvbnRhaW5zIG9u
bHkgc3RydWN0dXJlIGRlZmluaXRpb25zIHdpdGggc3BlY2lmaWMgI2RlZmluZXMgcGVyIGVhY2gg
ZmllbGQsIGFuZCBzb21lIG9mIHRob3NlIGRlZmluaXRpb25zIGluY2x1ZGUgZG91YmxlIGhpZXJh
cmNoeSAod2hpY2ggd2lsbCBiZSBsb3N0IGlmIHRoZXkgd2lsbCBhbGwgYmUgbGVmdCBhbGlnbmVk
KS4NCg0K
