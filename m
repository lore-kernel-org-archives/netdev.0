From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 06/10] amd-xgbe: Set DMA mask based on hardware
 register value
Date: Thu, 19 Mar 2015 17:32:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB046B5@AcuExch.aculab.com>
References: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
 <20150319171301.26446.71081.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>
To: 'Tom Lendacky' <thomas.lendacky@amd.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:65168 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030280AbbCSReR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 13:34:17 -0400
In-Reply-To: <20150319171301.26446.71081.stgit@tlendack-t1.amdoffice.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9tIExlbmRhY2t5DQo+IFRoZSBoYXJkd2FyZSBzdXBwbGllcyBhIHZhbHVlIHRoYXQg
aW5kaWNhdGVzIHRoZSBETUEgcmFuZ2UgdGhhdCBpdA0KPiBpcyBjYXBhYmxlIG9mIHVzaW5nLiBV
c2UgdGhpcyB2YWx1ZSByYXRoZXIgdGhhbiBoYXJkLWNvZGluZyBpdCBpbg0KPiB0aGUgZHJpdmVy
Lg0KLi4uDQo+ICsJLyogVHJhbnNsYXRlIHRoZSBhZGRyZXNzIHdpZHRoIHNldHRpbmcgaW50byBh
Y3R1YWwgbnVtYmVyICovDQo+ICsJc3dpdGNoIChod19mZWF0LT5kbWFfd2lkdGgpIHsNCj4gKwlj
YXNlIDA6DQo+ICsJCWh3X2ZlYXQtPmRtYV93aWR0aCA9IDMyOw0KPiArCQlicmVhazsNCj4gKwlj
YXNlIDE6DQo+ICsJCWh3X2ZlYXQtPmRtYV93aWR0aCA9IDQwOw0KPiArCQlicmVhazsNCj4gKwlj
YXNlIDI6DQo+ICsJCWh3X2ZlYXQtPmRtYV93aWR0aCA9IDQ4Ow0KPiArCQlicmVhazsNCj4gKwl9
DQo+ICsNCg0KSSBzZWUgYSBnbGFyaW5nIHByb2JsZW0gc2hvdWxkIHRoZSBoYXJkd2FyZSBldmVy
IHJldHVybiAzLg0KDQoJRGF2aWQNCg0K
