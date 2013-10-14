From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v4 3/5] xen-netback: Unconditionally set
 NETIF_F_RXCSUM
Date: Mon, 14 Oct 2013 11:03:17 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0138BE9@AMSPEX01CL01.citrite.net>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-4-git-send-email-paul.durrant@citrix.com>
 <1381748176.24708.103.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:51855 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874Ab3JNLF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 07:05:29 -0400
In-Reply-To: <1381748176.24708.103.camel@kazak.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJYW4gQ2FtcGJlbGwNCj4gU2Vu
dDogMTQgT2N0b2JlciAyMDEzIDExOjU2DQo+IFRvOiBQYXVsIER1cnJhbnQNCj4gQ2M6IHhlbi1k
ZXZlbEBsaXN0cy54ZW4ub3JnOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBXZWkgTGl1OyBEYXZp
ZCBWcmFiZWwNCj4gU3ViamVjdDogUmU6IFtQQVRDSCBuZXQtbmV4dCB2NCAzLzVdIHhlbi1uZXRi
YWNrOiBVbmNvbmRpdGlvbmFsbHkgc2V0DQo+IE5FVElGX0ZfUlhDU1VNDQo+IA0KPiBPbiBGcmks
IDIwMTMtMTAtMTEgYXQgMTY6MDYgKzAxMDAsIFBhdWwgRHVycmFudCB3cm90ZToNCj4gPiBUaGVy
ZSBpcyBubyBtZWNoYW5pc20gdG8gaW5zaXN0IHRoYXQgYSBndWVzdCBhbHdheXMgZ2VuZXJhdGVz
IGEgcGFja2V0DQo+ID4gd2l0aCBnb29kIGNoZWNrc3VtIChhdCBsZWFzdCBmb3IgSVB2NCkNCj4g
DQo+IElzbid0IHRoaXMgd2hhdCBmZWF0dXJlLW5vLWNzdW0tb2ZmbG9hZCBpcz8NCj4gDQoNClRo
ZW9yZXRpY2FsbHksIHllcywgYnV0IG5ldGJhY2sgZG9lcyBub3QgaGF2ZSBjb2RlIHRvIGFkdmVy
dGlzZSB0aGF0IGZsYWcgKGFuZCBuZXZlciBoYXM/KSBhbmQgSSBkb24ndCBzZWUgYW55dGhpbmcg
aW4geGVuLW5ldGZyb250IHRoYXQgY2hlY2tzIHN1Y2ggYSBmbGFnIHNvIEkgdGhpbmsgd2UgaGF2
ZSB0byBhc3N1bWUgaXQncyBub3QgZ29pbmcgdG8gYmUgaG9ub3VyZWQgZXZlbiBpZiB3ZSB3ZXJl
IHRvIGludHJvZHVjZSBpdCBub3cuDQoNCiAgUGF1bA0K
