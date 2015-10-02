From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/4] openvswitch: IPv6 support for
	ovs_tunnel_get_egress_info
Date: Fri, 2 Oct 2015 12:32:42 -0700
Message-ID: <CALnjE+qn7PrEYxKZ6c03-Bz63BcROVuqmwdp8sqi2eXvxY-yeg@mail.gmail.com>
References: <cover.1443710454.git.jbenc@redhat.com>
 <8eeae62b794d6d7486cedd8178414d2fdfb6e4f8.1443710454.git.jbenc@redhat.com>
 <CALnjE+o-ou=Vpv8_e20-CyRMA62ceGiDOZuSaRU9Qwb_WBBP8Q@mail.gmail.com>
 <20151002080041.52017d26@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20151002080041.52017d26@griffin>
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

T24gVGh1LCBPY3QgMSwgMjAxNSBhdCAxMTowMCBQTSwgSmlyaSBCZW5jIDxqYmVuY0ByZWRoYXQu
Y29tPiB3cm90ZToKPiBPbiBUaHUsIDEgT2N0IDIwMTUgMTc6MTE6NTYgLTA3MDAsIFByYXZpbiBT
aGVsYXIgd3JvdGU6Cj4+IEkgZG9udCBzZWUgcG9pbnQgb2YgYWRkaW5nIHRoaXMgY29kZSB3aGVu
IElQdjYgc2FtcGxpbmcgbm90IHN1cHBvcnQgYnkKPj4gdGhlIHBhdGNoIHNlcmllcy4KPgo+IEl0
IHdhcyByZXF1ZXN0ZWQgYnkgSmVzc2U6Cj4gaHR0cDovL2FydGljbGUuZ21hbmUub3JnL2dtYW5l
LmxpbnV4Lm5ldHdvcmsvMzgwMzQ4Cj4KCkkgZG9uJ3QgdGhpbmsgd2UgY2FuIHVzZSB0aGlzIGZ1
bmN0aW9uLCBsd3R1bm5lbCBkZXZpY2UgbmVlZCBuZXcgbmRvXwpvcGVyYXRpb24gdG8gZXhwb3J0
IHRoaXMgaW5mb3JtYXRpb24uIFNvIGxldHMgZGVmZXIgdGhpcyBwYXRjaCB0aWxsIHdlCmhhdmUg
c29sdXRpb24gZm9yIHJldHJpZXZpbmcgZWdyZXNzIGluZm8gZnJvbSBsd3R1bm5lbCBkZXZpY2Vz
LgoKPiBJIGRvbid0IG1pbmQgbGVhdmluZyB0aGlzIGFuZCB0aGUgcHJldmlvdXMgcGF0Y2ggb3V0
LCBpdCdzIGFjdHVhbGx5Cj4gd2hhdCBJIGRpZCBpbiB2MS4KPgo+ICBKaXJpCj4KPiAtLQo+IEpp
cmkgQmVuYwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpk
ZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
