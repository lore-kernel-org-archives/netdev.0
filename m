From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v21 3/4] openvswitch: 802.1AD Flow
 handling, actions, vlan parsing, netlink attributes
Date: Sun, 4 Sep 2016 13:05:46 +0200
Message-ID: <20160904130546.571fe654@griffin>
References: <1472762727-25844-1-git-send-email-e@erig.me>
 <1472762727-25844-4-git-send-email-e@erig.me>
 <CAOrHB_A6Twwp+S514orUZ5RaKS1hGXgc1uUi7Lj8dxPQrk_sxg@mail.gmail.com>
 <20160903173012.GJ31705@egarver>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Thomas F Herbert <thomasfherbert-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Eric Garver <e@erig.me>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20160903173012.GJ31705@egarver>
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

T24gU2F0LCAzIFNlcCAyMDE2IDEzOjMwOjEyIC0wNDAwLCBFcmljIEdhcnZlciB3cm90ZToKPiBX
b3VsZCBhIEJVR19PTighKGVuY2FwICYmIGluX2VuY2FwKSkgYmUgYmV0dGVyPwoKUGxlYXNlIGRv
bid0IGNyYXNoIHRoZSBrZXJuZWwgZm9yIHNvbWV0aGluZyB0aGF0IGNvdWxkIHZlcnkgd2VsbApj
b250aW51ZSB3aXRob3V0IHByb2JsZW1zLiBVc2UgV0FSTl9PTiBhdCBtb3N0LgoKQW5kIGlmIHlv
dSBnbyB0aGF0IHdheSwgV0FSTl9PTl9PTkNFIG9yIHJhdGUgbGltaXRpbmcgc2VlbXMgdG8gYmUg
ZXZlbgptb3JlIGFwcHJvcHJpYXRlLCBiZWNhdXNlIGlmIHRoaXMgdHJpZ2dlcnMsIGl0J3MgcXVp
dGUgcG9zc2libGUgaXQgd2lsbAp0cmlnZ2VyIHJlcGVhdGVkbHkgYW5kIHRoZSByZXN1bHRpbmcg
bG9nIGZsb29kIHdvdWxkIHByYWN0aWNhbGx5IG1ha2UKdGhlIG1hY2hpbmUgdXNlbGVzcyBhbnl3
YXkuCgpUaGFua3MsCgogSmlyaQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29w
ZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
