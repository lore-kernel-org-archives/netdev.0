From: James Bottomley <jbottomley@parallels.com>
Subject: Re: [PATCH net-next 2/2] random32: do not feed jiffies as seed from
 lpfc driver
Date: Fri, 1 Aug 2014 04:12:58 +0000
Message-ID: <1406866378.5442.9.camel@jarvis>
References: <1406837317-13648-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"james.smart@emulex.com" <james.smart@emulex.com>
To: "dborkman@redhat.com" <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([199.115.105.18]:34722 "EHLO
	mx2.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaHAENB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 00:13:01 -0400
In-Reply-To: <1406837317-13648-1-git-send-email-dborkman@redhat.com>
Content-Language: en-US
Content-ID: <ACBB9D686150F248BDF969E6695F5DAA@sw.swsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE0LTA3LTMxIGF0IDIyOjA4ICswMjAwLCBEYW5pZWwgQm9ya21hbm4gd3JvdGU6
DQo+IEluIHByYW5kb20gd2UgaGF2ZSBhbHJlYWR5IHJlc2VlZGluZyBtZWNoYW5pc21zIHRoYXQg
dHJpZ2dlcg0KPiBwZXJpb2RpY2FsbHkgZnJvbSBhIG11Y2ggYmV0dGVyIGVudHJvcHkgc291cmNl
IHRoYW4ganVzdA0KPiBmZWVkaW5nIGluIGppZmZpZXMgdGhyb3VnaCBscGZjX21ieF9jbXBsX2Zj
Zl9zY2FuX3JlYWRfZmNmX3JlYygpDQo+IFt3aGF0IGEgZnVuY3Rpb24gbmFtZSA4LSldLiBUaGVy
ZWZvcmUsIGp1c3QgcmVtb3ZlIHRoaXMuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBEYW5pZWwgQm9y
a21hbm4gPGRib3JrbWFuQHJlZGhhdC5jb20+DQo+IENjOiBKYW1lcyBCb3R0b21sZXkgPEpCb3R0
b21sZXlAUGFyYWxsZWxzLmNvbT4NCj4gQ2M6IEphbWVzIFNtYXJ0IDxqYW1lcy5zbWFydEBlbXVs
ZXguY29tPg0KPiAtLS0NCj4gIFRoaXMgY2FuIGFsc28gZ28gdmlhIEphbWVzLCBob3cgeW91IHBy
ZWZlciBpdC4NCg0KQ291bGQgeW91IHNlbmQgdG8gbGludXgtc2NzaUB2Z2VyLmtlcm5lbC5vcmc7
IENocmlzdG9waCBIZWxsd2lnIGlzDQpnYXRoZXJpbmcgcGF0Y2hlcyBmb3IgU0NTSSB2aWEgdGhh
dCBsaXN0Lg0KDQpUaGFua3MsDQoNCkphbWVzDQoNCg==
