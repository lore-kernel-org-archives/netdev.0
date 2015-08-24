From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] ila: Precompute checksums
Date: Sun, 23 Aug 2015 20:41:54 -0700 (PDT)
Message-ID: <20150823.204154.1884568868677636280.davem@davemloft.net>
References: <1440094958-1808151-1-git-send-email-tom@herbertland.com>
	<20150823.203843.1007208746644126304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbbHXDlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 23:41:55 -0400
In-Reply-To: <20150823.203843.1007208746644126304.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogU3VuLCAyMyBB
dWcgMjAxNSAyMDozODo0MyAtMDcwMCAoUERUKQ0KDQo+IEZyb206IFRvbSBIZXJiZXJ0IDx0b21A
aGVyYmVydGxhbmQuY29tPg0KPiBEYXRlOiBUaHUsIDIwIEF1ZyAyMDE1IDExOjIyOjM2IC0wNzAw
DQo+IA0KPj4gVGhpcyBwYXRjaCBzZXQ6DQo+PiAgLSBBZGRzIGFyZ3VtZW50IG90IExXVCBidWls
ZF9zdGF0ZSB0aGF0IGhvbGRzIGEgcG9pbnRlciB0byB0aGUgZmliDQo+PiAgICBjb25maWd1cmF0
aW9uIGJlaW5nIGFwcGxpZWQgdG8gdGhlIG5ldyByb3V0ZQ0KPj4gIC0gQWRkcyBzdXBwb3J0IGlu
IElMQSB0byBwcmVjb21wdXRlIGNoZWNrc3VtIGRpZmZlcmVuY2UgZm9yDQo+PiAgICBwZXJmb3Jt
YW5jZSBvcHRpbWl6YXRpb24NCj4+IA0KPj4gdjI6DQo+PiAgTW92ZSByZXR1cm4gYXJndW1lbnQg
aW4gYnVpbGRfc3RhdGUgdG8gZW5kIG9mIGFyZ3VtZW50cw0KPiANCj4gU2VyaWVzIGFwcGxpZWQs
IHRoYW5rcyBUb20uDQoNCkFjdHVhbGx5LCByZXZlcnRlZC4NCg0KWW91IG5lZWQgdG8gdXBkYXRl
IHRoZSBzaWduYXR1cmUgZm9yIGlwNl90dW5fYnVpbGRfc3RhdGUoKSB0b286DQoNCm5ldC9pcHY0
L2lwX3R1bm5lbF9jb3JlLmM6Mzk4OjI6IHdhcm5pbmc6IGluaXRpYWxpemF0aW9uIGZyb20gaW5j
b21wYXRpYmxlIHBvaW50ZXIgdHlwZQ0KICAuYnVpbGRfc3RhdGUgPSBpcDZfdHVuX2J1aWxkX3N0
YXRlLA0KICBeDQpuZXQvaXB2NC9pcF90dW5uZWxfY29yZS5jOjM5ODoyOiB3YXJuaW5nOiAobmVh
ciBpbml0aWFsaXphdGlvbiBmb3IgoWlwNl90dW5fbHd0X29wcy5idWlsZF9zdGF0ZaIpDQo=
