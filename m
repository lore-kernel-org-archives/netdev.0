From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: Fix compile error
Date: Tue, 19 Mar 2013 18:07:22 -0400 (EDT)
Message-ID: <20130319.180722.1735800542274116990.davem@davemloft.net>
References: <1363730481-7168-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: willemb@google.com, edumazet@google.com, netdev@vger.kernel.org
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab3CSWHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 18:07:24 -0400
In-Reply-To: <1363730481-7168-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGFuaWVsIEJhbHV0YSA8ZGJhbHV0YUBpeGlhY29tLmNvbT4NCkRhdGU6IFdlZCwgMjAg
TWFyIDIwMTMgMDA6MDE6MjEgKzAyMDANCg0KPiBQQUNLRVRfRkFOT1VUX1JPTExPVkVSIGFuZCBQ
QUNLRVRfRkFOT1VUX0ZMQUdfUk9MTE9WRVIgYXJlIG5vdCBkZWNsYXJlZCBpbg0KPiA8dHJlZT4v
dXNyL2luY2x1ZGUvbGludXgvaWZfcGFja2V0LmggdG9nZXRoZXIgd2l0aCB0aGUgb3RoZXIgUEFD
S0VUX0ZBTk9VVF8qIG1hY3Jvcw0KPiBhcyBvbmUgd291bGQgZXhwZWN0LiBUaGlzIGNhdXNlcyB0
aGUgZm9sbG93aW5nIGNvbXBpbGF0aW9uIGVycm9yOg0KPiA8c25pcD4NCj4gcHNvY2tfZmFub3V0
LmM6IEluIGZ1bmN0aW9uIKF0ZXN0X2NvbnRyb2xfc2luZ2xlojoNCj4gcHNvY2tfZmFub3V0LmM6
MjMwOjIzOiBlcnJvcjogoVBBQ0tFVF9GQU5PVVRfUk9MTE9WRVKiIHVuZGVjbGFyZWQgKGZpcnN0
IHVzZSBpbiB0aGlzIGZ1bmN0aW9uKQ0KPiA8L3NuaXA+DQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBE
YW5pZWwgQmFsdXRhIDxkYmFsdXRhQGl4aWFjb20uY29tPg0KDQpObywgaW4gZmFjdCwgYWxsIG9m
IHRoZXNlIHNob3VsZCBiZSByZW1vdmVkIGNvbXBsZXRlbHkuDQoNClRoZXkgYXJlIHByb3ZpZGVk
IGJ5IHRoZSBoZWFkZXIgZmlsZXMgdW5kZXIgbGludXgvdXNyL2luY2x1ZGUgd2hpY2gNCmdldCBj
cmVhdGVkIGJ5IHRoZSAibWFrZSBoZWFkZXJzX2luc3RhbGwiIHJ1bGUuDQoNClNvIHlvdSBlaXRo
ZXIgbmVlZCB0byBydW4gdGhlICJtYWtlIGhlYWRlcnNfaW5zdGFsbCIgcnVsZSBiZWZvcmUNCmJ1
aWxkaW5nIHRoZSB0ZXN0cywgb3IgaW5zdGFsbCB0aGUgdXBkYXRlZCBoZWFkZXJzIHVuZGVyIC91
c3IvaW5jbHVkZQ0Kb24geW91ciB0ZXN0IG1hY2hpbmUuDQoNCkknbGwgcmVtb3ZlIHRoZSBkZWZp
bmVzIGZyb20gdGhlIHRlc3QsIHRoYW5rcyBmb3IgcG9pbnRpbmcgdGhpcw0Kb3V0Lg0K
