From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] amd-xgbe: Rename MAX_DMA_CHANNELS to avoid powerpc
 conflict
Date: Mon, 9 Jun 2014 14:25:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17259A7D@AcuExch.aculab.com>
References: <20140609141931.30639.72028.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
	"jet.chen@intel.com" <jet.chen@intel.com>
To: 'Tom Lendacky' <thomas.lendacky@amd.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fengguang.wu@intel.com" <fengguang.wu@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40733 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933439AbaFIO0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 10:26:42 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16387-03 for <netdev@vger.kernel.org>;
 Mon,  9 Jun 2014 15:26:32 +0100 (BST)
In-Reply-To: <20140609141931.30639.72028.stgit@tlendack-t1.amdoffice.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9tIExlbmRhY2t5DQo+IE1BWF9ETUFfQ0hBTk5FTFMgaXMgZGVmaW5lZCBpbiBhc20v
c2NhdHRlcmxpc3QuaCBvZiB0aGUgcG93ZXJwYw0KPiBhcmNoaXRlY3R1cmUuICBSZW5hbWUgdGhp
cyAjZGVmaW5lIGluIHhnYmUuaCB0byBhdm9pZCB0aGUNCj4gcmVkZWZpbmVkIHdhcm5pbmcgaXNz
dWVkIGR1cmluZyBjb21waWxhdGlvbi4NCi4uLg0KPiAtLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5l
dC9hbWQveGdiZS94Z2JlLmgNCj4gKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvYW1kL3hnYmUv
eGdiZS5oDQo+IEBAIC0xMzgsNyArMTM4LDcgQEANCj4gICNkZWZpbmUgUlhfTUlOX0JVRl9TSVpF
CQkoRVRIX0ZSQU1FX0xFTiArIEVUSF9GQ1NfTEVOICsgVkxBTl9ITEVOKQ0KPiAgI2RlZmluZSBS
WF9CVUZfQUxJR04JCTY0DQo+IA0KPiAtI2RlZmluZSBNQVhfRE1BX0NIQU5ORUxTCTE2DQo+ICsj
ZGVmaW5lIFhHQkVfTUFYX0RNQV9DSEFOTkVMUwkxNg0KPiAgI2RlZmluZSBETUFfQVJET01BSU5f
U0VUVElORwkweDINCj4gICNkZWZpbmUgRE1BX0FSQ0FDSEVfU0VUVElORwkweGINCj4gICNkZWZp
bmUgRE1BX0FXRE9NQUlOX1NFVFRJTkcJMHgyDQoNCk1pZ2h0IGJlIHdvcnRod2hpbGUgY2hhbmdp
bmcgdGhlIG90aGVyIG5hbWVzIGF0IHRoZSBzYW1lIHRpbWUuDQoNCglEYXZpZA0KDQo=
