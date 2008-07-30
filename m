From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 15:37:58 -0700 (PDT)
Message-ID: <20080730.153758.91676696.davem@davemloft.net>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	<20080730.143532.124324888.davem@davemloft.net>
	<1217456666.18911.145.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53991
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753402AbYG3Wh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 18:37:58 -0400
In-Reply-To: <1217456666.18911.145.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWF0dCBNYWNrYWxsIDxtcG1Ac2VsZW5pYy5jb20+DQpEYXRlOiBXZWQsIDMwIEp1bCAy
MDA4IDE3OjI0OjI2IC0wNTAwDQoNCj4gDQo+IE9uIFdlZCwgMjAwOC0wNy0zMCBhdCAxNDozNSAt
MDcwMCwgRGF2aWQgTWlsbGVyIHdyb3RlOg0KPiA+IFRoaXMgY2hhbmdlIG1lYW5zIHlvdSBjYW4n
dCBjb25maWd1cmUgbmVhcmx5IGFsbCBvZiB0aGUgZmVhdHVyZXMgb24NCj4gPiB5b3VyIGV0aGVy
bmV0IGNhcmQuICBZb3UgY2FuJ3QgZXZlbiBjb25maWd1cmUgdGhlIGxpbmsgcGFyYW1ldGVycw0K
PiA+IHdpdGhvdXQgZXRodG9vbCBzdXBwb3J0Lg0KPiANCj4gV2hpY2ggaXMgYmlnIGZhdCBkb24n
dC1jYXJlIGZvciB0aGUgdmFzdCBtYWpvcml0eSBvZiB1c2Vycy4g77u/77u/VmFyaW91cw0KPiBw
b3B1bGFyIGRpc3Ryb3MgZG9uJ3QgZXZlbiBpbnN0YWxsIHRoZSB0b29sIGJ5IGRlZmF1bHQuDQoN
CkFyZSB5b3UgZXZlbiBhd2FyZSB0aGF0IHRoZSBldGh0b29sIGxheWVyIGdldHMgaW52b2tlZCBi
eSBzaW1wbHkNCmVuYWJsaW5nIElQIGZvcndhcmRpbmcgb3IgYnJpZGdpbmluZywgaW4gb3JkZXIg
dG8gZGlzYWJsZSBMUk8NCm9mZmxvYWRpbmcgd2hpY2ggY29uZmxpY3RzIHdpdGggc3VjaCB1c2Vz
Pw0KDQpBbmQgSSBkaXNhZ3JlZSB3aXRoIHlvdXIgYXNzZXJpb24gdGhhdCB0aGUgdG9vbCBkb2Vz
bid0IGdldCBpbnN0YWxsZWQNCmJ5IGRlZmF1bHQgYnkgZGlzdHJvcy4gIEkgY2FuJ3QgZmluZCBv
bmUgc2luZ2xlIHN5c3RlbSBoZXJlIHRoYXQNCmRvZXNuJ3QgaGF2ZSAvdXNyL3NiaW4vZXRodG9v
bCBhdmFpbGFibGUuDQoNCkkgZ3Vlc3MgaXQgZGVwZW5kcyB1cG9uIHlvdXIgZGVmaW5pdGlvbiBv
ZiAidmFyaW91cyIuDQo=
