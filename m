From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH net-next] igb: fix a compile warning
Date: Wed, 19 Oct 2011 09:28:54 -0700
Message-ID: <43F901BD926A4E43B106BF17856F075501A1776E6B@orsmsx508.amr.corp.intel.com>
References: <1319014355-15678-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: "roy.qing.li@gmail.com" <roy.qing.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52564 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844Ab1JSQ24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 12:28:56 -0400
In-Reply-To: <1319014355-15678-1-git-send-email-roy.qing.li@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10NCj4gT24gQmVo
YWxmIE9mIHJveS5xaW5nLmxpQGdtYWlsLmNvbQ0KPiBTZW50OiBXZWRuZXNkYXksIE9jdG9iZXIg
MTksIDIwMTEgMTo1MyBBTQ0KPiBUbzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPiBTdWJqZWN0
OiBbUEFUQ0ggbmV0LW5leHRdIGlnYjogZml4IGEgY29tcGlsZSB3YXJuaW5nDQo+IA0KPiBGcm9t
OiBSb25nUWluZyBMaSA8cm95LnFpbmcubGlAZ21haWwuY29tPg0KPiANCj4gY29udHJvbCB0aGVz
ZSB0aHJlZSBmdW5jdGlvbiBkZWNsYXJhdGlvbnMgYW5kDQo+IGRlZmluaXRpb25zIHdpdGggc2Ft
ZSBtYWNybyBDT05GSUdfUENJX0lPVg0KPiANCj4gZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwv
aWdiL2lnYl9tYWluLmM6MTY1Og0KPiB3YXJuaW5nOiDigJhpZ2JfdmZfY29uZmlndXJl4oCZIGRl
Y2xhcmVkIOKAmHN0YXRpY+KAmSBidXQgbmV2ZXIgZGVmaW5lZA0KPiBkcml2ZXJzL25ldC9ldGhl
cm5ldC9pbnRlbC9pZ2IvaWdiX21haW4uYzoxNjY6DQo+IHdhcm5pbmc6IOKAmGlnYl9maW5kX2Vu
YWJsZWRfdmZz4oCZIGRlY2xhcmVkIOKAmHN0YXRpY+KAmSBidXQgbmV2ZXIgZGVmaW5lZA0KPiBk
cml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9pZ2IvaWdiX21haW4uYzoxNjc6DQo+IHdhcm5pbmc6
IOKAmGlnYl9jaGVja192Zl9hc3NpZ25tZW504oCZIGRlY2xhcmVkIOKAmHN0YXRpY+KAmSBidXQg
bmV2ZXIgZGVmaW5lZA0KPiANCj4gU2lnbmVkLW9mZi1ieTogUm9uZ1FpbmcgTGkgPHJveS5xaW5n
LmxpQGdtYWlsLmNvbT4NCg0KQWNrZWQtYnk6IEdyZWcgUm9zZSA8Z3JlZ29yeS52LnJvc2VAaW50
ZWwuY29tPg0KDQo=
