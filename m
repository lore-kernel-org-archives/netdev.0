From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 2/2] net: dsa: lan9303: Learn addresses on CPU
 port when bridged
Date: Wed, 25 Oct 2017 15:48:53 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B8D2D7@CHN-SV-EXMX02.mchp-main.com>
References: <20171024093515.6749-1-privat@egil-hjelmeland.no>
 <20171024093515.6749-3-privat@egil-hjelmeland.no>
 <9235D6609DB808459E95D78E17F2E43D40B889C8@CHN-SV-EXMX02.mchp-main.com>
 <b0da2547-69d3-b323-6918-1022e112f7db@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: <privat@egil-hjelmeland.no>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:2856 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932205AbdJYPsz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 11:48:55 -0400
In-Reply-To: <b0da2547-69d3-b323-6918-1022e112f7db@egil-hjelmeland.no>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRWdpbCwNCg0KPiA+PiBAQCAtNjIsNyArODAsMTAgQEAgc3RhdGljIHN0cnVjdCBza19idWZm
ICpsYW45MzAzX3htaXQoc3RydWN0IHNrX2J1ZmYNCj4gKnNrYiwNCj4gPj4gc3RydWN0IG5ldF9k
ZXZpY2UgKmRldikNCj4gPj4NCj4gPj4gICAJbGFuOTMwM190YWcgPSAodTE2ICopKHNrYi0+ZGF0
YSArIDIgKiBFVEhfQUxFTik7DQo+ID4+ICAgCWxhbjkzMDNfdGFnWzBdID0gaHRvbnMoRVRIX1Bf
ODAyMVEpOw0KPiA+PiAtCWxhbjkzMDNfdGFnWzFdID0gaHRvbnMoZHAtPmluZGV4IHwgQklUKDQp
KTsNCj4gPj4gKwlsYW45MzAzX3RhZ1sxXSA9IGxhbjkzMDNfdHhfdXNlX2FybChkcCwgc2tiLT5k
YXRhKSA/DQo+ID4NCj4gPiBIb3cgYWJvdXQgdXNpbmcgc2tiX21hY19oZWFkZXIoc2tiKSB0aGFu
IHNrYi0+ZGF0YT8NCj4gPg0KPiA+PiArCQkJCUxBTjkzMDNfVEFHX1RYX1VTRV9BTFIgOg0KPiA+
PiArCQkJCWRwLT5pbmRleCB8DQo+ID4NCj4gDQo+IEkgYW0gbm90IHRoZSBleHBlcnQgaGVyZS4N
Cj4gDQo+IEkgc2VlIHRoYXQgc2tiX21hY19oZWFkZXIoKSBpcyAoc2tiLT5oZWFkICsgc2tiLT5t
YWNfaGVhZGVyKS4gU28gaXQgd2lsbA0KPiBjb3N0IGEgZmV3IG5hbm8gc2Vjb25kcyBwZXIgcGFj
a2V0LiBOb3QgdGhlIGVuZCBvZiB0aGUgd29ybGQgdGhvdWdoLg0KPiBCdXQgSSBzZWUgdGhhdCBv
dGhlciBuZXQvZHNhL3RhZ18qLmMgdXNlIHNrYi0+ZGF0YSwgYXNzdW1pbmcgdGhhdA0KPiBza2It
PmRhdGEgcG9pbnQgdG8gbWFjIGhlYWRlci4NCj4gDQoNClJldmlzaXRlZCBza2JfbWFjX2hlYWRl
cigpLiBJdCBpcyBiYXNpY2FsbHkgc2tiLT5kYXRhIGFmdGVyIG1hdGguDQpVbmRlcnN0YW5kIHRo
YXQgaXQgd291bGQgYmUgZXh0cmEgc3RlcHMgdGhhbiByZWZlcnJpbmcgc2tiLT5kYXRhIGRpcmVj
dGx5Lg0KVW5sZXNzIG5vIG9uZSBjb21tZW50cyBvbiB0aGlzLCBwbGVhc2Uga2VlcCBmaXJzdCBw
YXRjaC4NCg0KVGhhbmtzLg0KV29vanVuZw0K
