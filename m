From: pravin shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH] openvswitch: do not ignore netdev errors when
 creating tunnel vports
Date: Wed, 10 Aug 2016 10:26:16 -0700
Message-ID: <CAOrHB_D6Zi0TgTGRDr_mSidRox9O26YhPhkXGK3Yx4v7CjsDHw@mail.gmail.com>
References: <20160809152450.6626-1-martynas@weave.works>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Martynas Pumputis <martynas-1SEAoVOfG6VEzL6FDj/jAg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20160809152450.6626-1-martynas-1SEAoVOfG6VEzL6FDj/jAg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gVHVlLCBBdWcgOSwgMjAxNiBhdCA4OjI0IEFNLCBNYXJ0eW5hcyBQdW1wdXRpcyA8bWFydHlu
YXNAd2VhdmUud29ya3M+IHdyb3RlOgo+IFRoZSBjcmVhdGlvbiBvZiBhIHR1bm5lbCB2cG9ydCAo
Z2VuZXZlLCBncmUsIHZ4bGFuKSBicmluZ3MgdXAgYQo+IGNvcnJlc3BvbmRpbmcgbmV0ZGV2LCBh
IG11bHRpLXN0ZXAgb3BlcmF0aW9uIHdoaWNoIGNhbiBmYWlsLgo+Cj4gRm9yIGV4YW1wbGUsIGNo
YW5naW5nIGEgdnhsYW4gdnBvcnQncyBuZXRkZXYgc3RhdGUgdG8gJ3VwJyBiaW5kcyB0aGUKPiB2
cG9ydCdzIHNvY2tldCB0byBhIFVEUCBwb3J0IC0gaWYgdGhlIGJpbmRpbmcgZmFpbHMgKGUuZy4g
ZHVlIHRvIHRoZQo+IHBvcnQgYmVpbmcgaW4gdXNlKSwgdGhlIGVycm9yIGlzIGN1cnJlbnRseSBp
Z25vcmVkIGdpdmluZyB0aGUKPiBhcHBlYXJhbmNlIHRoYXQgdGhlIHR1bm5lbCB2cG9ydCBjcmVh
dGlvbiBjb21wbGV0ZWQgc3VjY2Vzc2Z1bGx5Lgo+Cj4gU2lnbmVkLW9mZi1ieTogTWFydHluYXMg
UHVtcHV0aXMgPG1hcnR5bmFzQHdlYXZlLndvcmtzPgoKVGhhbmtzLgoKQWNrZWQtYnk6IFByYXZp
biBCIFNoZWxhciA8cHNoZWxhckBvdm4ub3JnPgpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcK
aHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
