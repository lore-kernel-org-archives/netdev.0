From: "=?utf-8?B?6ZmI5Y2O5omN?=" <chenhc@lemote.com>
Subject: Re: [PATCH] stmmac: Don't init ptp again when resume fromsuspend/hibernation
Date: Fri, 19 Dec 2014 10:10:10 +0800
Message-ID: <tencent_3287080E294C08DF677CF32E@qq.com>
References: <1418884794-15483-1-git-send-email-chenhc@lemote.com>
	<20141218.153650.2242996610693466579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "=?utf-8?B?cGVwcGUuY2F2YWxsYXJv?=" <peppe.cavallaro@st.com>,
	"=?utf-8?B?dmJyaWRnZXJzMjAxMw==?=" <vbridgers2013@gmail.com>,
	"=?utf-8?B?bmV0ZGV2?=" <netdev@vger.kernel.org>,
	"=?utf-8?B?c3RhYmxl?=" <stable@vger.kernel.org>
To: "=?utf-8?B?RGF2aWQgTWlsbGVy?=" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20141218.153650.2242996610693466579.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SSBoYXZlIENDIG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcsIGJ1dCBJIGRvbid0IGtub3cgd2h5
IGl0IGRpZG4ndCByZWFjaCB0aGUgbWFpbGxpc3QuLi4NCkFueXdheSwgSSB3aWxsIHJlc2Vu
ZCB0aGUgcGF0Y2guDQogDQpIdWFjYWkNCiANCi0tLS0tLS0tLS0tLS0tLS0tLSBPcmlnaW5h
bCAtLS0tLS0tLS0tLS0tLS0tLS0NCkZyb206ICAiRGF2aWQgTWlsbGVyIjxkYXZlbUBkYXZl
bWxvZnQubmV0PjsNCkRhdGU6ICBGcmksIERlYyAxOSwgMjAxNCAwNDozNiBBTQ0KVG86ICAi
Y2hlbmhjIjxjaGVuaGNAbGVtb3RlLmNvbT47IA0KQ2M6ICAicGVwcGUuY2F2YWxsYXJvIjxw
ZXBwZS5jYXZhbGxhcm9Ac3QuY29tPjsgInZicmlkZ2VyczIwMTMiPHZicmlkZ2VyczIwMTNA
Z21haWwuY29tPjsgIm5ldGRldiI8bmV0ZGV2QHZnZXIua2VybmVsLm9yZz47ICJzdGFibGUi
PHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmc+OyANClN1YmplY3Q6ICBSZTogW1BBVENIXSBzdG1t
YWM6IERvbid0IGluaXQgcHRwIGFnYWluIHdoZW4gcmVzdW1lIGZyb21zdXNwZW5kL2hpYmVy
bmF0aW9uDQoNCiANCg0KVHdvIHByb2JsZW1zOg0KDQoxKSBUaGlzIHBvc3QgZGlkIG5vdCBy
ZWFjaCBuZXRkZXYgYW5kIHRoZXJlZm9yZSBkaWQgbm90IG1ha2UgaXQgaW50bw0KICAgcGF0
Y2h3b3JrIGZvciB0cmFja2luZy4gIFlvdSBuZWVkIHRvIGNvcnJlY3QgdGhpcy4NCg0KMikg
RG8gbm90IENDOiBzdGFibGUgb24gbmV0d29ya2luZyBjaGFuZ2VzLCBpbnN0ZWFkIGFzayBt
ZSBleHBsaWNpdGx5DQogICB0byBxdWV1ZSB0aGVtIHVwIGZvciAtc3RhYmxlIHN1Ym1pc3Np
b24gYW5kIHRvIHdoaWNoIHRyZWVzLg==
