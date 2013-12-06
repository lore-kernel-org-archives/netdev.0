From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Fri, 6 Dec 2013 11:15:58 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7469@saturn3.aculab.com>
References: <1385639832-3938-1-git-send-email-msekleta@redhat.com> <1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com> <5298A0EF.70401@redhat.com> <CAJ7VeQwC7xPPujCN8kQ3KcJAhykwQXLFA=vw2gWABmpUvuz1og@mail.gmail.com> <1386264770.30495.204.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com> <52A1A099.3010901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	=?UTF-8?B?TWljaGFsIFNla2xldMOhcg==?= <sekletar.m@gmail.com>,
	"Michal Sekletar" <msekleta@redhat.com>, <netdev@vger.kernel.org>,
	"Michael Kerrisk" <mtk.manpages@gmail.com>
To: "Daniel Borkmann" <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38587 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757657Ab3LFLQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 06:16:43 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10884-07 for <netdev@vger.kernel.org>;
 Fri,  6 Dec 2013 11:16:41 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <52A1A099.3010901@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBEYW5pZWwgQm9ya21hbm4gDQo+IE9uIDEyLzA2LzIwMTMgMTA6NTAgQU0sIERhdmlk
IExhaWdodCB3cm90ZToNCj4gPj4gaWYgU09fQlBGX0VYVEVOU0lPTlMgaXMgc3VwcG9ydGVkLCB0
aGFuIHlvdSBjYW4gYXNzdW1lIHRoYXQgYWxsIGN1cnJlbnQNCj4gPj4gZXh0ZW5zaW9ucyBhcmUg
c3VwcG9ydGVkLg0KPiA+Pg0KPiA+PiBObyBuZWVkIHRvIGNvbnN1bWUgb25lIGJpdCBwZXIgZmVh
dHVyZSwgYXMgYWxsIHRoZXNlIGZlYXR1cmVzIHdvbnQgZXZlcg0KPiA+PiBkaXNhcHBlYXIgZnJv
bSBsaW51eC4NCj4gPg0KPiA+IEhvd2V2ZXIgb25lIG9mIHRoZSBCU0RzIGNvdWxkIGFkZCBhIHN1
YnNldCBvZiB0aGUgZmVhdHVyZXMgYW5kDQo+ID4gd2lzaCB0byBhZHZlcnRpc2UgdGhlIGZhY3Qu
DQo+ID4gU28gdXNpbmcgZXh0cmEgZmxhZ3MgZm9yIG5vbi10cml2aWFsIGV4dGVuc2lvbnMgY291
bGQgYmUgdXNlZnVsLg0KPiANCj4gSGF2ZW4ndCBoYWQgYSBjbG9zZXIgbG9vayBhdCB0aGUgQlNE
IEJQRiBjb2RlIC95ZXQvLCBzbyAuLi4NCg0KSSd2ZSBub3QgbG9va2VkIGVpdGhlci4NCg0KPiAg
IGkpIERvZXMgQlNEIGhhdmUgc3VjaCBleHRlbnNpb25zIGFuZCBpZiBzbyBkbyB3ZSBvdmVybGFw
IHNvbWU/DQo+IA0KPiBpaSkgSXMgaXQgcGxhbm5lZCB0byBhbHNvIGludHJvZHVjZSBTT19CUEZf
RVhURU5TSU9OUyBmb3IgQlNEIGtlcm5lbHMNCj4gICAgICB0byBoYXZlIG9uZSBjb21tb24gYXBp
ICh0aGF0IGkuZS4gbGlicGNhcCB3b3VsZCB0aGVuIG1ha2UgdXNlIG9mKT8NCg0KSWYgaXQgaXMg
dXNlZnVsIHRvIGFkZCBhbnkgb2YgdGhlIGV4dGVuc2lvbnMsIGFuZCB0aGV5IGRvbid0IGNvbGxp
ZGUNCndpdGggYW55IG90aGVyIGV4aXN0aW5nIGNoYW5nZXMsIHRoZW4gdGhleSBtaWdodCBiZSBh
ZGRlZC4NCkFkZGluZyBhIHJlcXVlc3QgdGhhdCBpbmRpY2F0ZXMgd2hpY2ggZXh0ZW5zaW9ucyBh
cmUgc3VwcG9ydGVkIHNob3VsZA0KYmUgZWFzaWVyIHRoYW4gYWRkaW5nIHRoZSBleHRlbnNpb25z
IHRoZW1zZWx2ZXMuDQpBZGRpbmcgYWxsIHRoZSBMaW51eCBleHRlbnNpb25zIGF0IG9uY2UgY291
bGQgYmUgcHJvYmxlbWF0aWMuDQoNCglEYXZpZA0K
