From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH v4 1/3] VSOCK: Add vsockmon tap functions
Date: Thu, 20 Apr 2017 12:27:37 +0000
Message-ID: <F612F48C-8072-4588-B38A-2F366F53040A@vmware.com>
References: <20170413161811.8953-1-stefanha@redhat.com>
 <20170413161811.8953-2-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0056.outbound.protection.outlook.com ([104.47.38.56]:64345
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S945254AbdDTM1k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 08:27:40 -0400
In-Reply-To: <20170413161811.8953-2-stefanha@redhat.com>
Content-Language: en-US
Content-ID: <B02AF3513CDB7748A8EF6EAECD2F43F3@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+IE9uIEFwciAxMywgMjAxNywgYXQgNjoxOCBQTSwgU3RlZmFuIEhham5vY3ppIDxzdGVmYW5o
YUByZWRoYXQuY29tPiB3cm90ZToNCj4gDQo+ICsNCj4gK3N0YXRpYyB2b2lkIF9fdnNvY2tfZGVs
aXZlcl90YXAoc3RydWN0IHNrX2J1ZmYgKnNrYikNCj4gK3sNCj4gKwlpbnQgcmV0Ow0KPiArCXN0
cnVjdCB2c29ja190YXAgKnRtcDsNCj4gKw0KPiArCWxpc3RfZm9yX2VhY2hfZW50cnlfcmN1KHRt
cCwgJnZzb2NrX3RhcF9hbGwsIGxpc3QpIHsNCj4gKwkJcmV0ID0gX192c29ja19kZWxpdmVyX3Rh
cF9za2Ioc2tiLCB0bXAtPmRldik7DQo+ICsJCWlmICh1bmxpa2VseShyZXQpKQ0KPiArCQkJYnJl
YWs7DQo+ICsJfQ0KPiArDQo+ICsJY29uc3VtZV9za2Ioc2tiKTsNCg0KSXQgbG9va3MgbGlrZSB0
aGUgY2FsbGVyIHdpbGwgYWxsb2NhdGUgdGhlIHNrYiByZWdhcmRsZXNzIG9mIHdoZXRoZXIgdnNv
Y2tfdGFwX2FsbCBpcyBlbXB0eSwgc28gc2hvdWxkbuKAmXQgdGhlIHNrYiBiZSBjb25zdW1lZCBp
biB2c29ja19kZWxpdmVyX3RhcD8NCg0KPiArfQ0KPiArDQo+ICt2b2lkIHZzb2NrX2RlbGl2ZXJf
dGFwKHN0cnVjdCBza19idWZmICpza2IpDQo+ICt7DQo+ICsJcmN1X3JlYWRfbG9jaygpOw0KPiAr
DQo+ICsJaWYgKHVubGlrZWx5KCFsaXN0X2VtcHR5KCZ2c29ja190YXBfYWxsKSkpDQo+ICsJCV9f
dnNvY2tfZGVsaXZlcl90YXAoc2tiKTsNCj4gKw0KPiArCXJjdV9yZWFkX3VubG9jaygpOw0KPiAr
fQ0KPiArRVhQT1JUX1NZTUJPTF9HUEwodnNvY2tfZGVsaXZlcl90YXApOw0KPiAtLSANCj4gMi45
LjMNCj4gDQoNCg==
