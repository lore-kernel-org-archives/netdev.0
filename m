From: Harish Patil <harish.patil@qlogic.com>
Subject: Re: Linux kernel commit breaks IPMI on iface downing
Date: Wed, 9 Sep 2015 01:33:16 +0000
Message-ID: <D214D9E7.BFB25%harish.patil@qlogic.com>
References: <CAJPaPGU2_68J4BZanm+Lw3O+WTiwO3swegh5grP5Bn-XprLOwg@mail.gmail.com>
 <1439515834.7684.24.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CAJPaPGUsyHwaaTuUGcV5BMsSDcw1T7XQ9GVy5KwsMao3k8u+Kg@mail.gmail.com>
 <CAJPaPGU=8mWhrOSKRMnZjEULsBcO4PWkCsyUEfLfpY+cktyK_w@mail.gmail.com>
 <1441355399.8556.15.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Ameen Rahman" <ameen.rahman@qlogic.com>
To: Michael Chan <mchan@broadcom.com>,
	=?utf-8?B?U8OpYmFzdGllbiBCb2NhaHU=?= <sbu@reportlinker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41177 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753204AbbIIBdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 21:33:21 -0400
In-Reply-To: <1441355399.8556.15.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Content-Language: en-US
Content-ID: <62DBC5396F7D4449836C7596F5C165A7@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+T24gRnJpLCAyMDE1LTA5LTA0IGF0IDA5OjU1ICswMjAwLCBTw6liYXN0aWVuIEJvY2FodSB3
cm90ZToNCj4+IEhpLA0KPj4gDQo+PiBBbnkgY2hhbmNlIHRoaXMgYmVoYXZpb3VyIGdldHMgZml4
ZWQsIHdpdGggZWl0aGVyIGEgbmV3IGZpcm13YXJlIG9yIGENCj4+IHdvcmthcm91bmQgaW4gdGhl
IGtlcm5lbCA/DQo+PiANCj4NCj5BcyBJIHNhaWQgZWFybGllciwgd2hlbiB3ZSBjYWxsIGJueDJf
c2h1dGRvd25fY2hpcCgpLCB3ZSBpbmZvcm0gdGhlDQo+ZmlybXdhcmUgdGhhdCB0aGUgZHJpdmVy
IGlzIHNodXR0aW5nIGRvd24uICBUaGUgZmlybXdhcmUgc2hvdWxkIGtub3cNCj50aGF0IHRoZXJl
IGlzIElQTUkgZmlybXdhcmUgYW5kIHRoZSBsaW5rIG5lZWRzIHRvIHN0YXkgdXAuDQo+DQo+SW4g
dGhlIG9sZGVyIGRyaXZlciwgd2Ugd291bGQgYWxzbyBjYWxsIGJueDJfc2V0X3Bvd2VyX3N0YXRl
KCkgd2hpY2gNCj53b3VsZCBzZW5kIHNvbWUgYWRkaXRpb25hbCBtZXNzYWdlcyB0byB0aGUgZmly
bXdhcmUgYmVmb3JlIHB1dHRpbmcgdGhlDQo+ZGV2aWNlIGluIEQzaG90LiAgTWF5IGJlIHRoZXNl
IG1lc3NhZ2VzIGFyZSByZXF1aXJlZCBieSB0aGUgZmlybXdhcmUgdG8NCj5rZWVwIHRoZSBsaW5r
IHVwLiAgSGFyaXNoLCBwbGVhc2UgY2hlY2sgd2l0aCB5b3VyIGZpcm13YXJlIHRlYW0uDQo+VGhh
bmtzLg0KPg0KPg0KPg0KPg0KDQpIaSBNaWNoYWVsL1NlYmFzdGllbiwNCkFDSy4gU3VyZSwgSSB3
aWxsIGxvb2sgaW50byBpdCBhbmQgZ2V0IGJhY2suDQoNClRoYW5rcywNCkhhcmlzaA0KDQo=
