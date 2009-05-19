From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] sit: Fail to create tunnel, if it already exists
Date: Mon, 18 May 2009 19:31:45 -0700 (PDT)
Message-ID: <20090518.193145.257080801.davem@davemloft.net>
References: <1242396760-30568-1-git-send-email-contact@saschahlusiak.de>
	<20090518.154806.174728278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: contact@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43894
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752772AbZESCbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:31:47 -0400
In-Reply-To: <20090518.154806.174728278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogTW9uLCAxOCBN
YXkgMjAwOSAxNTo0ODowNiAtMDcwMCAoUERUKQ0KDQo+IA0KPiBBbGwgNSBwYXRjaGVzIGFwcGxp
ZWQgdG8gbmV0LW5leHQtMi42LCB0aGFua3MuDQoNCkFjdHVhbGx5LCBubywgSSByZXZlcnRlZCBh
bGwgb2YgdGhpcyBnYXJiYWdlLg0KDQpMZXQgbWUga25vdyB3aGVuIHlvdSBoYXZlIGEgdmVyc2lv
biBvZiB5b3VyIGNoYW5nZXMgdGhhdA0KYWN0dWFsbHkgY29tcGlsZS4NCg0KICBDQyBbTV0gIG5l
dC9pcHY2L3NpdC5vDQpuZXQvaXB2Ni9zaXQuYzogSW4gZnVuY3Rpb24g4oCYaXBpcDZfdHVubmVs
X3JzX3RpbWVy4oCZOg0KbmV0L2lwdjYvc2l0LmM6MjM1OiBlcnJvcjogaW5jb21wYXRpYmxlIHR5
cGUgZm9yIGFyZ3VtZW50IDEgb2Yg4oCYX3NwaW5fbG9ja+KAmQ0KbmV0L2lwdjYvc2l0LmM6MjU2
OiBlcnJvcjogaW52YWxpZCB0eXBlIGFyZ3VtZW50IG9mIOKAmC0+4oCZDQo=
