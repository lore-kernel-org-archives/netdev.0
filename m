From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp: missing destroy of percpu counter variable while
 unload module
Date: Wed, 05 Aug 2009 10:22:47 -0700 (PDT)
Message-ID: <20090805.102247.268018375.davem@davemloft.net>
References: <4A793867.3030104@cn.fujitsu.com>
	<4A793BE8.1060101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=gb2312
Content-Transfer-Encoding: base64
Cc: yjwei@cn.fujitsu.com, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37309
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934721AbZHERWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 13:22:40 -0400
In-Reply-To: <4A793BE8.1060101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogV2VkLCAw
NSBBdWcgMjAwOSAwOTo1OTozNiArMDIwMA0KDQo+IFdlaSBZb25nanVuIGEgqKZjcml0IDoNCj4+
IFNpZ25lZC1vZmYtYnk6IFdlaSBZb25nanVuIDx5andlaUBjbi5mdWppdHN1LmNvbT4NCiAuLi4N
Cj4gQWNrZWQtYnk6IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNvbT4NCj4gDQo+
IFRoaXMgd2FzIGFkZGVkIGJ5IGNvbW1pdCBkZDI0YzAwMSAobmV0OiBVc2UgYSBwZXJjcHVfY291
bnRlciBmb3Igb3JwaGFuX2NvdW50KQ0KPiAoVHVlIE5vdiAyNSAyMToxNzoxNCAyMDA4KSwgc28g
dGhpcyBjb3VsZCBiZSBhIHN0YWJsZSBjYW5kaWRhdGUgKDIuNi4yOSAmIDIuNi4zMCkNCg0KQXBw
bGllZCBhbmQgcXVldWVkIHVwIGZvciAtc3RhYmxlLCB0aGFua3MuDQo=
