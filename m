From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: openvswitch: Support masked set actions.
Date: Wed, 10 Dec 2014 18:03:47 -0800
Message-ID: <CAEP_g=8vm3+028GVdh-4DidOzpgfNiNQB7T1OqJ-_jOdPNU5Dw@mail.gmail.com>
References: <1418170225-9328-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1418170225-9328-1-git-send-email-jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

T24gVHVlLCBEZWMgOSwgMjAxNCBhdCA0OjEwIFBNLCBKYXJubyBSYWphaGFsbWUgPGpyYWphaGFs
bWVAbmljaXJhLmNvbT4gd3JvdGU6Cj4gZGlmZiAtLWdpdCBhL25ldC9vcGVudnN3aXRjaC9mbG93
X25ldGxpbmsuYyBiL25ldC9vcGVudnN3aXRjaC9mbG93X25ldGxpbmsuYwo+IGluZGV4IGRmM2M3
ZjIuLjI3NmJiNjAgMTAwNjQ0Cj4gLS0tIGEvbmV0L29wZW52c3dpdGNoL2Zsb3dfbmV0bGluay5j
Cj4gKysrIGIvbmV0L29wZW52c3dpdGNoL2Zsb3dfbmV0bGluay5jCj4gQEAgLTIwMDcsNiArMjEx
NywxOCBAQCBpbnQgb3ZzX25sYV9wdXRfYWN0aW9ucyhjb25zdCBzdHJ1Y3QgbmxhdHRyICphdHRy
LCBpbnQgbGVuLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQo+ICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgcmV0dXJuIGVycjsKPiAgICAgICAgICAgICAgICAgICAgICAgICBicmVhazsKPgo+
ICsgICAgICAgICAgICAgICBjYXNlIE9WU19BQ1RJT05fQVRUUl9TRVRfTUFTS0VEOgo+ICsgICAg
ICAgICAgICAgICAgICAgICAgIGVyciA9IG1hc2tlZF9zZXRfYWN0aW9uX3RvX2F0dHIoYSwgc2ti
KTsKPiArICAgICAgICAgICAgICAgICAgICAgICBpZiAoZXJyKQo+ICsgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgcmV0dXJuIGVycjsKPiArICAgICAgICAgICAgICAgICAgICAgICBicmVh
azsKCkkgZG9uJ3QgdGhpbmsgdGhpcyBpcyBuZWNlc3NhcnkgLSB0aGUgZGVmYXVsdCBjYXNlIHdp
bGwgaGFuZGxlIHRoaW5ncwp0aGF0IGRvbid0IG5lZWQgYW55IHNwZWNpYWwgcHJvY2Vzc2luZy4K
CkkgdGhpbmsgeW91IGNhbiBhbHNvIHJlbW92ZSB0aGUgcG9ydCBjaGVja3MgaW4gdmFsaWRhdGVf
dHBfcG9ydCgpCnNpbmNlIHRoZSByZWFzb25pbmcgYmVoaW5kIHRoZW0gaXMgdGhlIHNhbWUgYXMg
dGhlIElQIHByb3RvIGNoZWNrLgoKT3RoZXJ3aXNlLCBJJ20gZ2VuZXJhbGx5IGhhcHB5IHdpdGgg
dGhpcyB0aG91Z2guCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0
Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
