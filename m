From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 4/7] sctp: remove useless arguments from
 get_saddr() call
Date: Tue, 26 Apr 2011 00:12:27 -0700 (PDT)
Message-ID: <20110426.001227.112589346.davem@davemloft.net>
References: <4DB63F85.2090609@cn.fujitsu.com>
	<4DB6405B.2060200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757456Ab1DZHNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 03:13:00 -0400
In-Reply-To: <4DB6405B.2060200@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogV2VpIFlvbmdqdW4gPHlqd2VpQGNuLmZ1aml0c3UuY29tPg0KRGF0ZTogVHVlLCAyNiBB
cHIgMjAxMSAxMTo0NzozOSArMDgwMA0KDQo+IEBAIC0zOTIsMTEgKzM5MiwxMSBAQCBzdGF0aWMg
aW5saW5lIGludCBzY3RwX3Y2X2FkZHJfbWF0Y2hfbGVuKHVuaW9uIHNjdHBfYWRkciAqczEsDQo+
ICAgKi8NCj4gIHN0YXRpYyB2b2lkIHNjdHBfdjZfZ2V0X3NhZGRyKHN0cnVjdCBzY3RwX3NvY2sg
KnNrLA0KPiAgCQkJICAgICAgc3RydWN0IHNjdHBfdHJhbnNwb3J0ICp0LA0KPiAtCQkJICAgICAg
dW5pb24gc2N0cF9hZGRyICpkYWRkciwNCj4gIAkJCSAgICAgIHN0cnVjdCBmbG93aSAqZmwpDQo+
ICB7DQo+ICAJc3RydWN0IGZsb3dpNiAqZmw2ID0gJmZsLT51LmlwNjsNCj4gIAl1bmlvbiBzY3Rw
X2FkZHIgKnNhZGRyID0gJnQtPnNhZGRyOw0KPiArCXVuaW9uIHNjdHBfYWRkciAqZGFkZHIgPSAm
dC0+aXBhZGRyOw0KPiAgDQo+ICAJU0NUUF9ERUJVR19QUklOVEsoIiVzOiBhc29jOiVwIGRzdDol
cCBkYWRkcjolcEk2ICIsDQo+ICAJCQkgIF9fZnVuY19fLCB0LT5hc29jLCB0LT5kc3QsICZkYWRk
ci0+djYuc2luNl9hZGRyKTsNCg0KSSByZWFsbHkgZ2V0IGdydW1weSB3aGVuIEkgaGF2ZSB0byBm
aXggdXAgc3R1ZmYgbGlrZSB0aGlzOg0KDQpuZXQvc2N0cC9pcHY2LmM6IEluIGZ1bmN0aW9uIKFz
Y3RwX3Y2X2dldF9zYWRkcqI6DQpuZXQvc2N0cC9pcHY2LmM6MzgyOiB3YXJuaW5nOiB1bnVzZWQg
dmFyaWFibGUgoWRhZGRyog0KDQpZb3UgZ3V5cyBrbm93IEknbSBnb2luZyB0byBpbW1lZGlhdGVs
eSBydW4gbWFrZSBvbiBhbnkgcGF0Y2ggeW91IHNlbmQNCm1lIGFuZCBsb29rIGZvciBuZXcgd2Fy
bmluZ3MuDQoNCldoeSB3YXN0ZSBteSB0aW1lIGFuZCBub3QgbG9vayBmb3IgdGhlbSB5b3Vyc2Vs
dmVzIGJlZm9yZSBwb3N0aW5nIHRoZQ0KcGF0Y2g/DQoNClRoaXMgd2Fzbid0IGV2ZW4gb25lIG9m
IHRob3NlIGNhc2VzIHdoZXJlIHRoZSB3YXJuaW5nIGdvZXMgYXdheSBhdA0KdGhlIGVuZCBvZiB0
aGUgcGF0Y2ggc2VyaWVzLCBhbmQgb25seSBleGlzdHMgc29tZXdoZXJlIGluIHRoZSBtaWRkbGUu
DQoNCg==
