From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Fri, 6 Dec 2013 09:50:49 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com>
References: <1385639832-3938-1-git-send-email-msekleta@redhat.com> <1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com> <5298A0EF.70401@redhat.com> <CAJ7VeQwC7xPPujCN8kQ3KcJAhykwQXLFA=vw2gWABmpUvuz1og@mail.gmail.com> <1386264770.30495.204.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "Daniel Borkmann" <dborkman@redhat.com>,
	"Michal Sekletar" <msekleta@redhat.com>, <netdev@vger.kernel.org>,
	"Michael Kerrisk" <mtk.manpages@gmail.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	=?UTF-8?B?TWljaGFsIFNla2xldMOhcg==?= <sekletar.m@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36981 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757132Ab3LFJvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 04:51:33 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22516-09 for <netdev@vger.kernel.org>;
 Fri,  6 Dec 2013 09:51:31 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386264770.30495.204.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBpZiBTT19CUEZfRVhURU5TSU9OUyBpcyBzdXBwb3J0ZWQsIHRoYW4geW91IGNhbiBhc3N1bWUg
dGhhdCBhbGwgY3VycmVudA0KPiBleHRlbnNpb25zIGFyZSBzdXBwb3J0ZWQuDQo+IA0KPiBObyBu
ZWVkIHRvIGNvbnN1bWUgb25lIGJpdCBwZXIgZmVhdHVyZSwgYXMgYWxsIHRoZXNlIGZlYXR1cmVz
IHdvbnQgZXZlcg0KPiBkaXNhcHBlYXIgZnJvbSBsaW51eC4NCg0KSG93ZXZlciBvbmUgb2YgdGhl
IEJTRHMgY291bGQgYWRkIGEgc3Vic2V0IG9mIHRoZSBmZWF0dXJlcyBhbmQNCndpc2ggdG8gYWR2
ZXJ0aXNlIHRoZSBmYWN0Lg0KU28gdXNpbmcgZXh0cmEgZmxhZ3MgZm9yIG5vbi10cml2aWFsIGV4
dGVuc2lvbnMgY291bGQgYmUgdXNlZnVsLg0KDQoJRGF2aWQNCg0K
