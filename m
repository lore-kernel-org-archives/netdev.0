From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: add support for set/get rss hash key
Date: Tue, 09 Dec 2014 16:17:55 -0500 (EST)
Message-ID: <20141209.161755.669220277273811079.davem@davemloft.net>
References: <1417972273-22661-1-git-send-email-_govind@gmx.com>
	<20141209.161218.1737626879465253606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbaLIVR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:17:57 -0500
In-Reply-To: <20141209.161218.1737626879465253606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAwOSBE
ZWMgMjAxNCAxNjoxMjoxOCAtMDUwMCAoRVNUKQ0KDQo+IEZyb206IEdvdmluZGFyYWp1bHUgVmFy
YWRhcmFqYW4gPF9nb3ZpbmRAZ214LmNvbT4NCj4gRGF0ZTogU3VuLCAgNyBEZWMgMjAxNCAyMjo0
MToxMyArMDUzMA0KPiANCj4+IFRoaXMgcGF0Y2ggYWRkcyBzdXBwb3J0IGZvciBzZXR0aW5nL2dl
dHRpbmcgcnNzIGhhc2gga2V5IHVzaW5nIGV0aHRvb2wuDQo+PiANCj4+IFNpZ25lZC1vZmYtYnk6
IEdvdmluZGFyYWp1bHUgVmFyYWRhcmFqYW4gPF9nb3ZpbmRAZ214LmNvbT4NCj4gDQo+IEFwcGxp
ZWQsIHRoYW5rcy4NCg0KSG1tbS4uLg0KDQpkcml2ZXJzL25ldC9ldGhlcm5ldC9jaXNjby9lbmlj
L2VuaWNfZXRodG9vbC5jOjQ2MToyOiB3YXJuaW5nOiBpbml0aWFsaXphdGlvbiBmcm9tIGluY29t
cGF0aWJsZSBwb2ludGVyIHR5cGUgW2VuYWJsZWQgYnkgZGVmYXVsdF0NCmRyaXZlcnMvbmV0L2V0
aGVybmV0L2Npc2NvL2VuaWMvZW5pY19ldGh0b29sLmM6NDYxOjI6IHdhcm5pbmc6IChuZWFyIGlu
aXRpYWxpemF0aW9uIGZvciChZW5pY19ldGh0b29sX29wcy5nZXRfcnhmaKIpIFtlbmFibGVkIGJ5
IGRlZmF1bHRdDQpkcml2ZXJzL25ldC9ldGhlcm5ldC9jaXNjby9lbmljL2VuaWNfZXRodG9vbC5j
OjQ2MjoyOiB3YXJuaW5nOiBpbml0aWFsaXphdGlvbiBmcm9tIGluY29tcGF0aWJsZSBwb2ludGVy
IHR5cGUgW2VuYWJsZWQgYnkgZGVmYXVsdF0NCmRyaXZlcnMvbmV0L2V0aGVybmV0L2Npc2NvL2Vu
aWMvZW5pY19ldGh0b29sLmM6NDYyOjI6IHdhcm5pbmc6IChuZWFyIGluaXRpYWxpemF0aW9uIGZv
ciChZW5pY19ldGh0b29sX29wcy5zZXRfcnhmaKIpIFtlbmFibGVkIGJ5IGRlZmF1bHRdDQoNClRo
ZSBmdW5jdGlvbiBzaWduYXR1cmUgaGFzIGNoYW5nZWQgZm9yIHRoaXMgbWV0aG9kLCB5b3UgbmVl
ZCB0byB1cGRhdGUgdGhpcw0KcGF0Y2ggYW5kIHJlc3VibWl0Lg0KDQpJJ3ZlIHJldmVydGVkIGl0
IGZvciBub3cuDQo=
