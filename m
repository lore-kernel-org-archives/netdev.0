From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] selftests/bpf: fix broken build of
 test_maps
Date: Mon, 23 Oct 2017 01:06:46 +0100 (WEST)
Message-ID: <20171023.010646.1411430473371443955.davem@davemloft.net>
References: <20171022172906.3131400-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: daniel@iogearbox.net, brakmo@fb.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932139AbdJWAGt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 20:06:49 -0400
In-Reply-To: <20171022172906.3131400-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGVpIFN0YXJvdm9pdG92IDxhc3RAZmIuY29tPg0KRGF0ZTogU3VuLCAyMiBPY3Qg
MjAxNyAxMDoyOTowNiAtMDcwMA0KDQo+IGZpeCBtdWx0aXBsZSBidWlsZCBlcnJvcnMgYW5kIHdh
cm5pbmdzDQo+IA0KPiAxLg0KPiB0ZXN0X21hcHMuYzogSW4gZnVuY3Rpb24goXRlc3RfbWFwX3Jk
b25seaI6DQo+IHRlc3RfbWFwcy5jOjEwNTE6MzA6IGVycm9yOiChQlBGX0ZfUkRPTkxZoiB1bmRl
Y2xhcmVkIChmaXJzdCB1c2UgaW4gdGhpcyBmdW5jdGlvbikNCj4gICAgICAgICBNQVBfU0laRSwg
bWFwX2ZsYWdzIHwgQlBGX0ZfUkRPTkxZKTsNCj4gDQo+IDIuDQo+IHRlc3RfbWFwcy5jOjEwNDg6
Njogd2FybmluZzogdW51c2VkIHZhcmlhYmxlIKFpoiBbLVd1bnVzZWQtdmFyaWFibGVdDQo+ICAg
aW50IGksIGZkLCBrZXkgPSAwLCB2YWx1ZSA9IDA7DQo+IA0KPiAzLg0KPiB0ZXN0X21hcHMuYzox
MDg3OjI6IGVycm9yOiBjYWxsZWQgb2JqZWN0IGlzIG5vdCBhIGZ1bmN0aW9uIG9yIGZ1bmN0aW9u
IHBvaW50ZXINCj4gICBhc3NlcnQoYnBmX21hcF9sb29rdXBfZWxlbShmZCwgJmtleSwgJnZhbHVl
KSA9PSAtMSAmJiBlcnJubyA9PSBFUEVSTSk7DQo+IA0KPiA0Lg0KPiAuL2JwZl9oZWxwZXJzLmg6
NzI6MTE6IGVycm9yOiB1c2Ugb2YgdW5kZWNsYXJlZCBpZGVudGlmaWVyICdCUEZfRlVOQ19nZXRz
b2Nrb3B0Jw0KPiAgICAgICAgICh2b2lkICopIEJQRl9GVU5DX2dldHNvY2tvcHQ7DQo+IA0KPiBG
aXhlczogZTA0MzMyNWIzMDg3ICgiYnBmOiBBZGQgdGVzdHMgZm9yIGVCUEYgZmlsZSBtb2RlIikN
Cj4gRml4ZXM6IDZlNzFiMDRhODIyNCAoImJwZjogQWRkIGZpbGUgbW9kZSBjb25maWd1cmF0aW9u
IGludG8gYnBmIG1hcHMiKQ0KPiBGaXhlczogY2Q4NmQxZmQyMTAyICgiYnBmOiBBZGRpbmcgaGVs
cGVyIGZ1bmN0aW9uIGJwZl9nZXRzb2Nrb3BzIikNCj4gU2lnbmVkLW9mZi1ieTogQWxleGVpIFN0
YXJvdm9pdG92IDxhc3RAa2VybmVsLm9yZz4NCj4gQWNrZWQtYnk6IERhbmllbCBCb3JrbWFubiA8
ZGFuaWVsQGlvZ2VhcmJveC5uZXQ+DQoNCkFwcGxpZWQsIHRoYW5rcyBBbGV4ZWkuDQo=
