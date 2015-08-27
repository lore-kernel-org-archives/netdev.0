From: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Subject: RE: [Question] Usage of dev_hold()/dev_put()
Date: Thu, 27 Aug 2015 01:05:07 +0000
Message-ID: <60A73B7A161A82449A7DB7B382BFD15537141CC2@SZXEMA504-MBS.china.huawei.com>
References: <60A73B7A161A82449A7DB7B382BFD155371410A6@SZXEMA504-MBS.china.huawei.com>
	 <1440512689.8932.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <60A73B7A161A82449A7DB7B382BFD15537141B06@SZXEMA504-MBS.china.huawei.com>
 <1440594621.8932.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Qinchuanyu <qinchuanyu@huawei.com>, Yewudi <yewudi@huawei.com>,
	liuyongan 00175866 <l00175866@notesmail.huawei.com.cn>,
	Wangbicheng <wangbicheng@huawei.com>,
	Yan Chen <Y.Chen@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:31577 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbbH0BFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 21:05:21 -0400
In-Reply-To: <1440594621.8932.21.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VmVyeSBjbGVhciBleHBsYW5hdGlvbu+8jHRoYW5rIHlvdSEgOi0pDQoNClpoYW5namllDQoNCi0t
LS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQpGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0bzplcmlj
LmR1bWF6ZXRAZ21haWwuY29tXSANClNlbnQ6IFdlZG5lc2RheSwgQXVndXN0IDI2LCAyMDE1IDk6
MTAgUE0NClRvOiBaaGFuZ2ppZSAoSFopDQpDYzogSmFzb24gV2FuZzsgbmV0ZGV2QHZnZXIua2Vy
bmVsLm9yZzsgUWluY2h1YW55dTsgWWV3dWRpOyBsaXV5b25nYW4gMDAxNzU4NjY7IFdhbmdiaWNo
ZW5nOyBZYW4gQ2hlbg0KU3ViamVjdDogUmU6IFtRdWVzdGlvbl0gVXNhZ2Ugb2YgZGV2X2hvbGQo
KS9kZXZfcHV0KCkNCg0KT24gV2VkLCAyMDE1LTA4LTI2IGF0IDA3OjQ4ICswMDAwLCBaaGFuZ2pp
ZSAoSFopIHdyb3RlOg0KPiBFcmljLA0KPiBUaGFuayB5b3UgZm9yIHlvdXIgcGF0aWVudCBhcHBs
eS4NCj4gVGhlcmUgaXMgc3RpbGwgYSBxdWVzdGlvbiwgDQo+IEluIHJlY2VpdmUgcGF0aCwgZHJp
dmVyIGRvZXMgbm90IGNhbGwgZGV2X2hvbGQoKSwgd2hlbiBza2IgZ29lcyB0byBob3N0IHN0YWNr
LCBza2ItPmRldiBpcyBsaWtlbHkgdG8gYmUgdXNlZC4gDQo+IElmIGRldmljZSBpcyBkZXN0cm95
ZWQgYmVmb3JlIHRoYXQsIGl0IHNlZW1zIGRhbmdlcm91cy4NCg0KVGhpcyBpcyBhbHNvIGhhbmRs
ZWQgcHJvcGVybHkuDQoNCkNoZWNrIDogZmx1c2hfYmFja2xvZygpIGluIG5ldC9jb3JlL2Rldi5j
DQogICBzb2NrX3F1ZXVlX3Jjdl9za2IoKSAsIGFuZCBhbGwgZnVuY3Rpb25zIHNldHRpbmcgc2ti
LT5kZXYgdG8gTlVMTA0KDQoNCg==
