From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH net 1/7] qlge: Fixed packet transmit errors due to
 potential driver errors.
Date: Tue, 3 Jul 2012 15:33:37 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA877435B27EC@AVEXMB1.qlogic.org>
References: <20120702.171854.1585295090835924398.davem@davemloft.net>
	 <5E4F49720D0BAD499EE1F01232234BA877435B266A@AVEXMB1.qlogic.org>
	 <20120702.183826.1521103644475572622.davem@davemloft.net>
	 <20120702.184134.1131493483786674336.davem@davemloft.net>
	 <5E4F49720D0BAD499EE1F01232234BA877435B2797@AVEXMB1.qlogic.org>
 <1341347235.2583.796.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	"krkumar2@in.ibm.com" <krkumar2@in.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:16863
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998Ab2GCWdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 18:33:43 -0400
In-Reply-To: <1341347235.2583.796.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogRXJpYyBEdW1hemV0IFttYWls
dG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0gDQo+U2VudDogVHVlc2RheSwgSnVseSAwMywgMjAx
MiAxOjI3IFBNDQo+VG86IEppdGVuZHJhIEthbHNhcmlhDQo+Q2M6IERhdmlkIE1pbGxlcjsgbmV0
ZGV2OyBSb24gTWVyY2VyOyBEZXB0LU5YIExpbnV4IE5JQyBEcml2ZXINCj5TdWJqZWN0OiBSRTog
W1BBVENIIG5ldCAxLzddIHFsZ2U6IEZpeGVkIHBhY2tldCB0cmFuc21pdCBlcnJvcnMgZHVlIHRv
IHBvdGVudGlhbCBkcml2ZXIgZXJyb3JzLg0KPg0KPk9uIFR1ZSwgMjAxMi0wNy0wMyBhdCAxMjoz
OCAtMDcwMCwgSml0ZW5kcmEgS2Fsc2FyaWEgd3JvdGU6DQo+DQo+SSBiZWxpZXZlIGV2ZXJ5Ym9k
eSBraW5kbHkgYXNrIHlvdSB0byBmaXggdGhlIGRyaXZlciBsb2dpYyBpbnN0ZWFkDQo+b2YgdHJ5
aW5nIHRvIGhpZGUgdG8geW91ciBjdXN0b21lcnMgdGhlIHByb2JsZW1zLg0KPg0KPkluIGZhY3Qs
IHlvdSBjb3VsZCBqdXN0IEJVRygpIGF0IHRoaXMgcG9pbnQsIGFuZCBtYXliZSBEYXZpZCB3aWxs
IGFjY2VwdA0KPnN1Y2ggYSBwYXRjaC4NCj4NCj50ZXN0aW5nIGF0b21pY19yZWFkKCZ0eF9yaW5n
LT50eF9jb3VudCkgYXQgdGhlIGJlZ2lubmluZyBvZiBxbGdlX3NlbmQoKQ0KPmlzIHRvbyBsYXRl
LiBORVRERVZfVFhfQlVTWSBpcyBkZXByZWNhdGVkLg0KPg0KPldlbGwgYmVoYXZpbmcgZHJpdmVy
cyBzaG91bGQgcGVyZm9ybSB0aGUgdGVzdCBhdCB0aGUgZW5kIG9mIHRoZWlyDQo+bmRvX3N0YXJ0
X3htaXQoKSBhbmQgc3RvcCB0aGUgcXVldWUgc28gdGhhdCBuZXh0IHBhY2tldCB3b250IGNvbWUg
YXQNCj5hbGwuDQoNClRoYW5rcyBldmVyeW9uZSBhbmQgd2lsbCBkZWZpbml0ZWx5IGNoYW5nZSB0
aGUgbG9naWMuDQoNCg0KDQo=
