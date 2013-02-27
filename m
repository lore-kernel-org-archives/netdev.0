From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/sctp: Validate parameter size for
 SCTP_GET_ASSOC_STATS
Date: Wed, 27 Feb 2013 16:08:50 -0500 (EST)
Message-ID: <20130227.160850.660037788307311215.davem@davemloft.net>
References: <1361998651-19354-1-git-send-email-linux@roeck-us.net>
	<512E73FA.1090407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: linux@roeck-us.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, sri@us.ibm.com, nhorman@tuxdriver.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab3B0VIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 16:08:52 -0500
In-Reply-To: <512E73FA.1090407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVmxhZCBZYXNldmljaCA8dnlhc2V2aWNoQGdtYWlsLmNvbT4NCkRhdGU6IFdlZCwgMjcg
RmViIDIwMTMgMTY6MDA6NDIgLTA1MDANCg0KPiBPbiAwMi8yNy8yMDEzIDAzOjU3IFBNLCBHdWVu
dGVyIFJvZWNrIHdyb3RlOg0KPj4gQnVpbGRpbmcgc2N0cCBtYXkgZmFpbCB3aXRoOg0KPj4NCj4+
IEluIGZ1bmN0aW9uIKFjb3B5X2Zyb21fdXNlcqIsDQo+PiAgICAgIGlubGluZWQgZnJvbSChc2N0
cF9nZXRzb2Nrb3B0X2Fzc29jX3N0YXRzoiBhdA0KPj4gICAgICBuZXQvc2N0cC9zb2NrZXQuYzo1
NjU2OjIwOg0KPj4gYXJjaC94ODYvaW5jbHVkZS9hc20vdWFjY2Vzc18zMi5oOjIxMToyNjogZXJy
b3I6IGNhbGwgdG8NCj4+ICAgICAgoWNvcHlfZnJvbV91c2VyX292ZXJmbG93oiBkZWNsYXJlZCB3
aXRoIGF0dHJpYnV0ZSBlcnJvcjoNCj4+ICAgICAgY29weV9mcm9tX3VzZXIoKQ0KPj4gICAgICBi
dWZmZXIgc2l6ZSBpcyBub3QgcHJvdmFibHkgY29ycmVjdA0KPj4NCj4+IGlmIGJ1aWx0IHdpdGgg
Vz0xIGR1ZSB0byBhIG1pc3NpbmcgcGFyYW1ldGVyIHNpemUgdmFsaWRhdGlvbg0KPj4gYmVmb3Jl
IHRoZSBjYWxsIHRvIGNvcHlfZnJvbV91c2VyLg0KPj4NCj4+IFNpZ25lZC1vZmYtYnk6IEd1ZW50
ZXIgUm9lY2sgPGxpbnV4QHJvZWNrLXVzLm5ldD4NCj4+IC0tLQ0KPj4gdjI6IEZpeCBieSBtb3Zp
bmcgdGhlIGV4aXN0aW5nIHBhcmFtZXRlciBzaXplIHZhbGlkYXRpb24gdXANCj4+ICAgICAgaW4g
dGhlIGZ1bmN0aW9uIGluc3RlYWQgb2YgYWRkaW5nIGFuIGFkZGl0aW9uYWwgb25lLg0KPiANCj4g
VGhpcyB3b3JrcyB0b28uLi4NCj4gDQo+IEFja2VkLWJ5OiBWbGFkIFlhc2V2aWNoIDx2eWFzZXZp
Y2hAZ21haWwuY29tPg0KDQpJJ2xsIGFwcGx5IHRoaXMgYW5kIHF1ZXVlIGl0IHVwIGZvciAtc3Rh
YmxlLCB0aGFua3MgZXZlcnlvbmUuDQo=
