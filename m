From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] net: dsa: Multi-CPU ground work (v3)
Date: Tue, 13 Jun 2017 16:13:46 -0400 (EDT)
Message-ID: <20170613.161346.1504304537662026135.davem@davemloft.net>
References: <20170613191725.26625-1-f.fainelli@gmail.com>
        <20170613.161113.1646399895545825339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753898AbdFMUNx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:13:53 -0400
In-Reply-To: <20170613.161113.1646399895545825339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAxMyBK
dW4gMjAxNyAxNjoxMToxMyAtMDQwMCAoRURUKQ0KDQo+IEZyb206IEZsb3JpYW4gRmFpbmVsbGkg
PGYuZmFpbmVsbGlAZ21haWwuY29tPg0KPiBEYXRlOiBUdWUsIDEzIEp1biAyMDE3IDEyOjE3OjIx
IC0wNzAwDQo+IA0KPj4gVGhpcyBwYXRjaCBzZXJpZXMgcHJlcGFyZXMgdGhlIGdyb3VuZCBmb3Ig
YWRkaW5nIG11dGxpcGxlIENQVSBwb3J0IHN1cHBvcnQgdG8NCj4+IERTQSwgYW5kIHN0YXJ0cyBi
eSByZW1vdmluZyByZWR1bmRhbnQgcGllY2VzIG9mIGluZm9ybWF0aW9uIHN1Y2ggYXMNCj4+IG1h
c3Rlcl9uZXRkZXYgd2hpY2ggaXMgY3B1X2RwLT5ldGhlcm5ldC4gRmluYWxseSBkcml2ZXJzIGFy
ZSBtb3ZlZCBhd2F5IGZyb20NCj4+IGRpcmVjdGx5IGFjY2Vzc2luZyBkcy0+ZHN0LT5jcHVfZHAg
YW5kIHVzZSBhcHByb3ByaWF0ZSBoZWxwZXIgZnVuY3Rpb25zLg0KPj4gDQo+PiBOb3RlIHRoYXQg
aWYgeW91IGhhdmUgRGV2aWNlIFRyZWUgYmxvYnMvcGxhdGZvcm0gY29uZmlndXJhdGlvbnMgdGhh
dCBhcmUNCj4+IGN1cnJlbnRseSBsaXN0aW5nIG11bHRpcGxlIENQVSBwb3J0cywgdGhlIHByb3Bv
c2VkIGJlaGF2aW9yIGluDQo+PiBkc2FfZHNfZ2V0X2NwdV9kcCgpIHdpbGwgYmUgdG8gcmV0dXJu
IHRoZSBsYXN0IGJpdCBzZXQgaW4gZHMtPmNwdV9wb3J0X21hc2suDQo+PiANCj4+IEZ1dHVyZSBw
bGFucyBpbmNsdWRlOg0KPj4gLSBtYWtpbmcgZHN0LT5jcHVfZHAgYSBmbGV4aWJsZSBkYXRhIHN0
cnVjdHVyZSAoYXJyYXksIGxpc3QsIHlvdSBuYW1lIGl0KQ0KPj4gLSBoYXZpbmcgdGhlIGFiaWxp
dHkgZm9yIGRyaXZlcnMgdG8gcmV0dXJuIGEgZGVmYXVsdC9wcmVmZXJyZWQgQ1BVIHBvcnQgKGlm
DQo+PiAgIG5lY2Vzc2FyeSkNCj4gIC4uLg0KPiANCj4gU2VyaWVzIGFwcGxpZWQsIHRoYW5rcyBG
bG9yaWFuLg0KDQpBY3R1YWxseSwgSSByZXZlcnRlZCwgdGhpcyBpbnRyb2R1Y2VkIGEgd2Fybmlu
ZywgcGxlYXNlIGJ1aWxkIHdpdGggTkVUUE9MTA0KZW5hYmxlZDoNCg0KbmV0L2RzYS9zbGF2ZS5j
OiBJbiBmdW5jdGlvbiChZHNhX3NsYXZlX25ldHBvbGxfc2V0dXCiOg0KbmV0L2RzYS9zbGF2ZS5j
OjY4ODoyMTogd2FybmluZzogdW51c2VkIHZhcmlhYmxlIKFkc6IgWy1XdW51c2VkLXZhcmlhYmxl
XQ0KICBzdHJ1Y3QgZHNhX3N3aXRjaCAqZHMgPSBwLT5kcC0+ZHM7DQo=
