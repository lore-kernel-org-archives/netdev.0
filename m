From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [patch -next] caif: add error handling for allocation
Date: Fri, 2 Sep 2011 11:40:23 +0200
Message-ID: <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
References: <20110902080716.GF2430@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	"open list:CAIF NETWORK LAYER" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:45589 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932779Ab1IBJkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 05:40:24 -0400
In-Reply-To: <20110902080716.GF2430@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRGFuLAouLi4KPiDCoCDCoCDCoCDCoHN3aXRjaCAocGh5X3R5cGUpIHsKPiDCoCDCoCDCoCDC
oGNhc2UgQ0ZQSFlUWVBFX0ZSQUc6Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBwaHlfZHJpdmVy
ID0KPiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoGNmc2VybF9jcmVhdGUoQ0ZQSFlUWVBF
X0ZSQUcsIHBoeWlkLCBzdHgpOwo+IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgaWYgKCFwaHlfZHJp
dmVyKQo+IC0gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgZ290byBvdXQ7Cj4gKyDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBnb3RvIG91dF9lcnI7Cj4gwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqBicmVhazsKLi4uCj4gLW91dDoKPiArIMKgIMKgIMKgIG11dGV4X3VubG9j
aygmY25mZy0+bG9jayk7Cj4gKyDCoCDCoCDCoCByZXR1cm47Cj4gKwo+ICtvdXRfZXJyOgo+ICsg
wqAgwqAgwqAga2ZyZWUocGh5aW5mbyk7Cj4gwqAgwqAgwqAgwqBtdXRleF91bmxvY2soJmNuZmct
PmxvY2spOwoKVGhhbmsgeW91IGZvciB5b3VyIHBhdGNoLgpXaGVuIHJldmlld2luZyB0aGlzIEkg
Zm91bmQgYW5vdGhlciBwb3RlbnRpYWwgbWVtb3J5IGxlYWsgYXMgd2VsbC4KSWYgY2Zmcm1sX2Ny
ZWF0ZSBmYWlscywgd2UgbWlnaHQgYmUgbGVha2luZyB0aGUgcGh5X2RyaXZlci4KU28gcGVyaGFw
cyB5b3UgY291bGQgZG8ga2ZyZWUocGh5X2RyaXZlcikgaW4gb3V0X2VycjogYXMgd2VsbCwgd2hp
bGUKeW91IGFyZSBhdCBpdD8KClJlZ2FyZHMsClNqdXIK
