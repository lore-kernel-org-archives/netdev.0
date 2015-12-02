From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net] openvswitch: fix hangup on
	vxlan/gre/geneve device deletion
Date: Wed, 2 Dec 2015 15:00:33 -0800
Message-ID: <CALnjE+ow8CdKrzMjGWR3O1xHsaaCa3hX34S4oEoop2-7+YRwxQ@mail.gmail.com>
References: <d3c53f79dfaacd71bebf97427388d60dc5652eae.1448989843.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Flavio Leitner <fbl-ljGZA5MgXf9g9hUCZPvPmw@public.gmane.org>
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <d3c53f79dfaacd71bebf97427388d60dc5652eae.1448989843.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

T24gVHVlLCBEZWMgMSwgMjAxNSBhdCA5OjMzIEFNLCBQYW9sbyBBYmVuaSA8cGFiZW5pQHJlZGhh
dC5jb20+IHdyb3RlOgo+IEVhY2ggb3BlbnZzd2l0Y2ggdHVubmVsIHZwb3J0ICh2eGxhbixncmUs
Z2VuZXZlKSBob2xkcyBhIHJlZmVyZW5jZQo+IHRvIHRoZSB1bmRlcmx5aW5nIHR1bm5lbCBkZXZp
Y2UsIGJ1dCBuZXZlciByZWxlYXNlZCBpdCB3aGVuIHN1Y2gKPiBkZXZpY2UgaXMgZGVsZXRlZC4K
PiBEZWxldGluZyB0aGUgdW5kZXJseWluZyBkZXZpY2UgdmlhIHRoZSBpcCB0b29sIGNhdXNlIHRo
ZSBrZXJuZWwgdG8KPiBoYW5ndXAgaW4gdGhlIG5ldGRldl93YWl0X2FsbHJlZnMoKSBsb29wLgo+
IFRoaXMgY29tbWl0IGVuc3VyZSB0aGF0IG9uIGRldmljZSB1bnJlZ2lzdHJhdGlvbiBkcF9kZXRh
Y2hfcG9ydF9ub3RpZnkoKQo+IGlzIGNhbGxlZCBmb3IgYWxsIHZwb3J0cyB0aGF0IGhvbGQgdGhl
IGRldmljZSByZWZlcmVuY2UsIHByb3Blcmx5Cj4gcmVsZWFzaW5nIGl0Lgo+Cj4gRml4ZXM6IDYx
NDczMmVhYTEyZCAoIm9wZW52c3dpdGNoOiBVc2UgcmVndWxhciBWWExBTiBuZXRfZGV2aWNlIGRl
dmljZSIpCj4gRml4ZXM6IGIyYWNkMWRjMzk0OSAoIm9wZW52c3dpdGNoOiBVc2UgcmVndWxhciBH
UkUgbmV0X2RldmljZSBpbnN0ZWFkIG9mIHZwb3J0IikKPiBGaXhlczogNmIwMDFlNjgyZTkwICgi
b3BlbnZzd2l0Y2g6IFVzZSBHZW5ldmUgZGV2aWNlLiIpCj4gU2lnbmVkLW9mZi1ieTogUGFvbG8g
QWJlbmkgPHBhYmVuaUByZWRoYXQuY29tPgoKVGhhbmtzIGZvciB0aGUgZml4LgpBY2tlZC1ieTog
UHJhdmluIEIgU2hlbGFyIDxwc2hlbGFyQG5pY2lyYS5jb20+Cl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dp
dGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
