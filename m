From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Remove unnecessary comparison of unsigned
 against 0
Date: Tue, 18 Oct 2016 10:25:47 -0400 (EDT)
Message-ID: <20161018.102547.1252630571952098432.davem@davemloft.net>
References: <20161018064417.26379-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: kaber@trash.net, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42114 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761203AbcJROZt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 10:25:49 -0400
In-Reply-To: <20161018064417.26379-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9iaWFzIEtsYXVzZXIgPHRrbGF1c2VyQGRpc3RhbnouY2g+DQpEYXRlOiBUdWUsIDE4
IE9jdCAyMDE2IDA4OjQ0OjE3ICswMjAwDQoNCj4gYXJncy51Lm5hbWVfdHlwZSBpcyBvZiB0eXBl
IHVuc2lnbmVkIGludCBhbmQgaXMgYWx3YXlzID49IDAuDQo+IA0KPiBUaGlzIGZpeGVzIHRoZSBm
b2xsb3dpbmcgR0NDIHdhcm5pbmc6DQo+IA0KPiAgIG5ldC84MDIxcS92bGFuLmM6IEluIGZ1bmN0
aW9uIKF2bGFuX2lvY3RsX2hhbmRsZXKiOg0KPiAgIG5ldC84MDIxcS92bGFuLmM6NTc0OjE0OiB3
YXJuaW5nOiBjb21wYXJpc29uIG9mIHVuc2lnbmVkIGV4cHJlc3Npb24gPj0gMCBpcyBhbHdheXMg
dHJ1ZSBbLVd0eXBlLWxpbWl0c10NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFRvYmlhcyBLbGF1c2Vy
IDx0a2xhdXNlckBkaXN0YW56LmNoPg0KDQpBcHBsaWVkIHRvIG5ldC1uZXh0LCB0aGFua3MuDQo=
