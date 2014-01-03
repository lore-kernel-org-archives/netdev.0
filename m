From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: revert "sched classifier: make cgroup
 table local"
Date: Thu, 02 Jan 2014 19:03:23 -0500 (EST)
Message-ID: <20140102.190323.819558246638891031.davem@davemloft.net>
References: <1388703521-5535-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaACAEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:04:11 -0500
In-Reply-To: <1388703521-5535-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQ29uZyBXYW5nIDx4aXlvdS53YW5nY29uZ0BnbWFpbC5jb20+DQpEYXRlOiBUaHUsICAy
IEphbiAyMDE0IDE0OjU4OjQxIC0wODAwDQoNCj4gVGhpcyByZXZlcnRzIGNvbW1pdCBkZTZmYjI4
OGIxMjQ2YTVjNGUwMGMwY2RiZmUzYTgzOGEzNjBiM2Y0Lg0KPiBPdGhlcndpc2Ugd2UgZ290Og0K
PiANCj4gbmV0L3NjaGVkL2Nsc19jZ3JvdXAuYzoxMDY6Mjk6IGVycm9yOiBzdGF0aWMgZGVjbGFy
YXRpb24gb2YgoW5ldF9jbHNfc3Vic3lzoiBmb2xsb3dzIG5vbi1zdGF0aWMgZGVjbGFyYXRpb24N
Cj4gIHN0YXRpYyBzdHJ1Y3QgY2dyb3VwX3N1YnN5cyBuZXRfY2xzX3N1YnN5cyA9IHsNCj4gICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICBeDQo+IEluIGZpbGUgaW5jbHVkZWQgZnJvbSBpbmNs
dWRlL2xpbnV4L2Nncm91cC5oOjY1NDowLA0KPiAgICAgICAgICAgICAgICAgIGZyb20gbmV0L3Nj
aGVkL2Nsc19jZ3JvdXAuYzoxODoNCj4gaW5jbHVkZS9saW51eC9jZ3JvdXBfc3Vic3lzLmg6MzU6
Mjk6IG5vdGU6IHByZXZpb3VzIGRlY2xhcmF0aW9uIG9mIKFuZXRfY2xzX3N1YnN5c6Igd2FzIGhl
cmUNCj4gIFNVQlNZUyhuZXRfY2xzKQ0KPiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIF4N
Cj4gbWFrZVsyXTogKioqIFtuZXQvc2NoZWQvY2xzX2Nncm91cC5vXSBFcnJvciAxDQo+IA0KPiBD
YzogU3RlcGhlbiBIZW1taW5nZXIgPHN0ZXBoZW5AbmV0d29ya3BsdW1iZXIub3JnPg0KPiBDYzog
RGF2aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KPiBTaWduZWQtb2ZmLWJ5OiBD
b25nIFdhbmcgPHhpeW91Lndhbmdjb25nQGdtYWlsLmNvbT4NCg0KVGhpcyBpcyBzbyBkYW1uIHVu
aW50dWl0aXZlLCBhbmQgdGhhdCBidWlsZCBlcnJvciBvbmx5IG9jY3VycyBpZiB5b3UNCmJ1aWxk
IGNsc19jZ3JvdXAgc3RhdGljYWxseS4NCg0KQXBwbGllZCwgYnV0IHRoZSB3YXkgdGhpcyB3b3Jr
cyBpcyB0ZXJyaWJsZS4NCg==
