From: "Woodhouse, David" <david.woodhouse@intel.com>
Subject: Re: [patch] solos-pci: double lock in geos_gpio_store()
Date: Thu, 20 Dec 2012 09:22:26 +0000
Message-ID: <1355995348.18919.104.camel@shinybook.infradead.org>
References: <20121220074845.GA14716@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	Nathan Williams <nathan@traverse.com.au>,
	"linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kbuild@01.org" <kbuild@01.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33470 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917Ab2LTJWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 04:22:45 -0500
In-Reply-To: <20121220074845.GA14716@elgon.mountain>
Content-Language: en-US
Content-ID: <56F588C53BFE3942B7DFACE5FC3CBEB7@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDEyLTEyLTIwIGF0IDEwOjQ4ICswMzAwLCBEYW4gQ2FycGVudGVyIHdyb3RlOg0K
PiBUaGVyZSBpcyBhIHR5cG8gaGVyZSBzbyB3ZSBkbyBhIGRvdWJsZSBsb2NrIGluc3RlYWQgb2Yg
YW4gdW5sb2NrLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogRGFuIENhcnBlbnRlciA8ZGFuLmNhcnBl
bnRlckBvcmFjbGUuY29tPg0KPiAtLS0NCj4gT25seSBuZWVkZWQgaW4gbGludXgtbmV4dC4gIElu
dHJvZHVjZWQgaW4gZjliYWFkMDJlNzQxMWQ5IFsxNC8xN10NCj4gc29sb3MtcGNpOiBhZGQgR1BJ
TyBzdXBwb3J0IGZvciBuZXdlciB2ZXJzaW9ucyBvbiBHZW9zIGJvYXJkDQoNCkFoLCBjcmFwLiBU
aGF0IHdhcyBteSBmYXVsdDsgaXQgd2FzIHBhcnQgb2YgbXkgImltcHJvdmVtZW50IiB0byBOYXRo
YW4ncw0KcGF0Y2guIFNvcnJ5Lg0KDQpBY2tlZC1ieTogRGF2aWQgV29vZGhvdXNlIDxEYXZpZC5X
b29kaG91c2VAaW50ZWwuY29tPg0KDQo=
