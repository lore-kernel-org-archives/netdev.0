From: pravin shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next v22 2/3] vlan: Check for vlan
 ethernet types for 8021.q or 802.1ad
Date: Wed, 7 Sep 2016 18:20:12 -0700
Message-ID: <CAOrHB_AJ_VZLMCdh_DOppR-iyFRzVivowtnEtAf8fR1kH08+6Q@mail.gmail.com>
References: <1473267419-6825-1-git-send-email-e@erig.me>
 <1473267419-6825-3-git-send-email-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Thomas F Herbert <thomasfherbert-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Eric Garver <e@erig.me>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1473267419-6825-3-git-send-email-e-jCUjZXiOoP8@public.gmane.org>
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

T24gV2VkLCBTZXAgNywgMjAxNiBhdCA5OjU2IEFNLCBFcmljIEdhcnZlciA8ZUBlcmlnLm1lPiB3
cm90ZToKPiBUaGlzIGlzIHRvIHNpbXBsaWZ5IHVzaW5nIGRvdWJsZSB0YWdnZWQgdmxhbnMuIFRo
aXMgZnVuY3Rpb24gYWxsb3dzIGFsbAo+IHZhbGlkIHZsYW4gZXRoZXJ0eXBlcyB0byBiZSBjaGVj
a2VkIGluIGEgc2luZ2xlIGZ1bmN0aW9uIGNhbGwuCj4gQWxzbyByZXBsYWNlIHNvbWUgaW5zdGFu
Y2VzIHRoYXQgY2hlY2sgZm9yIGJvdGggRVRIX1BfODAyMVEgYW5kCj4gRVRIX1BfODAyMUFELgo+
Cj4gUGF0Y2ggYmFzZWQgb24gb25lIG9yaWdpbmFsbHkgYnkgVGhvbWFzIEYgSGVyYmVydC4KPgo+
IFNpZ25lZC1vZmYtYnk6IFRob21hcyBGIEhlcmJlcnQgPHRob21hc2ZoZXJiZXJ0QGdtYWlsLmNv
bT4KPiBTaWduZWQtb2ZmLWJ5OiBFcmljIEdhcnZlciA8ZUBlcmlnLm1lPgoKQWNrZWQtYnk6IFBy
YXZpbiBCIFNoZWxhciA8cHNoZWxhckBvdm4ub3JnPgpfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5v
cmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
