From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net 1/2] qlcnic: Do not force adapter to perform LRO
 without destination IP check
Date: Wed, 30 Oct 2013 06:46:02 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46EE8FC4@avmb2.qlogic.org>
References: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
	 <1382711917-28501-2-git-send-email-shahed.shaikh@qlogic.com>
 <1382761028.4032.36.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:35770 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379Ab3J3GqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 02:46:05 -0400
In-Reply-To: <1382761028.4032.36.camel@edumazet-glaptop.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBTYXR1cmRheSwgT2N0b2JlciAyNiwg
MjAxMyA5OjQ3IEFNDQo+IFRvOiBTaGFoZWQgU2hhaWtoDQo+IENjOiBEYXZpZCBNaWxsZXI7IG5l
dGRldjsgRGVwdC1OWCBMaW51eCBOSUMgRHJpdmVyDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0
IDEvMl0gcWxjbmljOiBEbyBub3QgZm9yY2UgYWRhcHRlciB0byBwZXJmb3JtIExSTw0KPiB3aXRo
b3V0IGRlc3RpbmF0aW9uIElQIGNoZWNrDQo+IA0KPiBPbiBGcmksIDIwMTMtMTAtMjUgYXQgMTA6
MzggLTA0MDAsIFNoYWhlZCBTaGFpa2ggd3JvdGU6DQo+ID4gRnJvbTogU2hhaGVkIFNoYWlraCA8
c2hhaGVkLnNoYWlraEBxbG9naWMuY29tPg0KPiA+DQo+ID4gRm9yY2luZyBhZGFwdGVyIHRvIHBl
cmZvcm0gTFJPIHdpdGhvdXQgZGVzdGluYXRpb24gSVAgY2hlY2sgZGVncmFkZXMNCj4gPiB0aGUg
cGVyZm9ybWFuY2UuDQo+IA0KPiANCj4gSG1tLi4uIHRoZSBwZXJmb3JtYW5jZSwgb3IgZG9lcyBp
dCBhbGxvdyB0d28gcGFja2V0cyBiZWxvbmdpbmcgdG8gZGlmZmVyZW50DQo+IGZsb3dzIGJlaW5n
IHdyb25nbHkgYWdncmVnYXRlZCA/DQo+IA0KPiBJdCBsb29rcyBhIGNyaXRpY2FsIGJ1ZyBmaXgs
IG5vdCBvbmx5IGEgcGVyZm9ybWFuY2UgaXNzdWUuDQoNCkhpIEVyaWMsDQoNClRoYXQncyBub3Qg
dGhlIGNhc2UuIFdoZW4gIGRlc3RpbmF0aW9uIElQIGNoZWNrIGlzIHNraXBwZWQsIGR1ZSB0byBh
IGZpcm13YXJlIGJ1Zywgc29tZSBwYWNrZXRzIHRha2UgYSBzbG93ZXIgcGF0aCBsZWFkaW5nIHRv
IHBlcmZvcm1hbmNlIGlzc3Vlcy4NCk9uY2UgdGhlIGZpcm13YXJlIGlzc3VlIGlzIHJlc29sdmVk
IHdlIHdpbGwgcmV2ZXJ0IHRoaXMgY2hhbmdlIGluIHRoZSBkcml2ZXIgdG8gc2tpcCB0aGUgZGVz
IHRpcCBjaGVjay4NCg0KVGhhbmtzLA0KU2hhaGVkDQo=
