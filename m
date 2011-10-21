From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add const qualifiers where possible
Date: Fri, 21 Oct 2011 03:36:48 -0400 (EDT)
Message-ID: <20111021.033648.1029307040209750463.davem@davemloft.net>
References: <1319179993.2854.63.camel@edumazet-laptop>
	<20111021.025549.113655582134326444.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841Ab1JUHgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 03:36:53 -0400
In-Reply-To: <20111021.025549.113655582134326444.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUByZWRoYXQuY29tPg0KRGF0ZTogRnJpLCAyMSBPY3Qg
MjAxMSAwMjo1NTo0OSAtMDQwMCAoRURUKQ0KDQo+IEZyb206IEVyaWMgRHVtYXpldCA8ZXJpYy5k
dW1hemV0QGdtYWlsLmNvbT4NCj4gRGF0ZTogRnJpLCAyMSBPY3QgMjAxMSAwODo1MzoxMyArMDIw
MA0KPiANCj4+IEFkZGluZyBjb25zdCBxdWFsaWZpZXJzIHRvIHBvaW50ZXJzIGNhbiBlYXNlIGNv
ZGUgcmV2aWV3LCBhbmQgc3BvdCBzb21lDQo+PiBidWdzLiBJdCBtaWdodCBhbGxvdyBjb21waWxl
ciB0byBvcHRpbWl6ZSBjb2RlIGZ1cnRoZXIuDQo+PiANCj4+IEZvciBleGFtcGxlLCBpcyBpdCBs
ZWdhbCB0byB0ZW1wb3Jhcnkgd3JpdGUgYSBudWxsIGNrc3VtIGludG8gdGNwaGRyDQo+PiBpbiB0
Y3BfbWQ1X2hhc2hfaGVhZGVyKCkgPyBJIGFtIGFmcmFpZCBhIHNuaWZmZXIgY291bGQgY2F0Y2gg
dGhlDQo+PiB0ZW1wb3JhcnkgbnVsbCB2YWx1ZS4uLg0KPj4gDQo+PiBTaWduZWQtb2ZmLWJ5OiBF
cmljIER1bWF6ZXQgPGVyaWMuZHVtYXpldEBnbWFpbC5jb20+DQo+IA0KPiBBcHBsaWVkLg0KDQpZ
b3UgY2FuJ3QgbWFrZSB0aGUgYXJndW1lbnQgdG8gX19za19kc3RfZ2V0KCkgY29uc3QsIGJlY2F1
c2UgbG9ja19pc19oZWxkKCkNCmRvZXMgbm90IHRha2UgYSBjb25zdCBwb2ludGVyIGFyZ3VtZW50
Lg0KDQppbmNsdWRlL25ldC9zb2NrLmg6IEluIGZ1bmN0aW9uIKFfX3NrX2RzdF9nZXSiOg0KaW5j
bHVkZS9uZXQvc29jay5oOjEzMTU6Mjogd2FybmluZzogcGFzc2luZyBhcmd1bWVudCAxIG9mIKFs
b2NrX2lzX2hlbGSiIGRpc2NhcmRzIKFjb25zdKIgcXVhbGlmaWVyIGZyb20gcG9pbnRlciB0YXJn
ZXQgdHlwZSBbZW5hYmxlZCBieSBkZWZhdWx0XQ0KaW5jbHVkZS9saW51eC9sb2NrZGVwLmg6MzI0
OjEyOiBub3RlOiBleHBlY3RlZCChc3RydWN0IGxvY2tkZXBfbWFwICqiIGJ1dCBhcmd1bWVudCBp
cyBvZiB0eXBlIKFjb25zdCBzdHJ1Y3QgbG9ja2RlcF9tYXAgKqINCg0KSSdtIHJldmVydGluZy4N
Cg==
