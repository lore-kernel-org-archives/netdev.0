From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 8 Oct 2013 14:01:36 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B737B@saturn3.aculab.com>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org> (sfid-20131008_133333_304168_2D31449F) <1381233152.13359.10.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Ard Biesheuvel" <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <1381233152.13359.10.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiBIbW0sIHRoYW5rcyBJIGd1ZXNzLiBJJ2xsIG5lZWQgdG8gcmV2aWV3IHRoaXMgaW4gbW9yZSBk
ZXRhaWwsIGJ1dCBJIGhhdmUNCj4gYSBxdWVzdGlvbiBmaXJzdDoNCj4gDQo+ID4gKwkvKiBhbGxv
Y2F0ZSB0aGUgdmFyaWFibGUgc2l6ZWQgYWVhZF9yZXF1ZXN0IG9uIHRoZSBzdGFjayAqLw0KPiA+
ICsJaW50IGwgPSBESVZfUk9VTkRfVVAoY3J5cHRvX2FlYWRfcmVxc2l6ZSh0Zm0pLA0KPiA+ICsJ
CQkgICAgIHNpemVvZihzdHJ1Y3QgYWVhZF9yZXF1ZXN0KSk7DQo+ID4gKwlzdHJ1Y3QgYWVhZF9y
ZXF1ZXN0IHJlcVsxICsgbF07DQo+IA0KPiBUaGlzIGxvb2tzIGEgYml0IG9kZCwgd2h5IHJvdW5k
IHVwIGZpcnN0IGFuZCB0aGVuIGFkZCBvbmU/IFdoeSBldmVuDQo+IGJvdGhlciB1c2luZyBhIHN0
cnVjdCBhcnJheSByYXRoZXIgdGhhbiBzb21lIGxvY2FsIHN0cnVjdCBsaWtlDQoNCklzIGl0IGV2
ZW4gYSBnb29kIGlkZWEgdG8gYmUgYWxsb2NhdGluZyB2YXJpYWJsZSBzaXplZCBpdGVtcw0Kb24g
dGhlIGtlcm5lbCBzdGFjaz8NCg0KVGhlcmUgaGFzIHRvIGJlIGVub3VnaCBzdGFjayBhdmFpbGFi
bGUgZm9yIHRoZSBtYXhpbXVtIG51bWJlcg0Kb2YgZW50cmllcyAtIHNvIHRoZXJlIGlzIGxpdHRs
ZSBwb2ludCBpbiBkeW5hbWljYWxseSBzaXppbmcgaXQuDQoNCglEYXZpZA0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
