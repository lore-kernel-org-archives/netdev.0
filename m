From: "Du, Fan" <fan.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [Discussion] About over-MTU-sized skb in virtualized env
Date: Wed, 3 Dec 2014 05:40:15 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848DEE159@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, "Du,
 Fan" <fan.du-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org" <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Language: en-US
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

SGkgRmxvcmlhbg0KDQoyMTQgc3RhdGljIGludCBpcF9maW5pc2hfb3V0cHV0X2dzbyhzdHJ1Y3Qg
c2tfYnVmZiAqc2tiKQ0KIDIxNSB7DQogMjE2ICAgICBuZXRkZXZfZmVhdHVyZXNfdCBmZWF0dXJl
czsNCiAyMTcgICAgIHN0cnVjdCBza19idWZmICpzZWdzOw0KIDIxOCAgICAgaW50IHJldCA9IDA7
DQogMjE5DQogMjIwICAgICAvKiBjb21tb24gY2FzZTogbG9jYWxseSBjcmVhdGVkIHNrYiBvciBz
ZWdsZW4gaXMgPD0gbXR1ICovDQogMjIxICAgICBpZiAoKChJUENCKHNrYiktPmZsYWdzICYgSVBT
S0JfRk9SV0FSREVEKSA9PSAwKSB8fA0KIDIyMiAgICAgICAgICAgc2tiX2dzb19uZXR3b3JrX3Nl
Z2xlbihza2IpIDw9IGlwX3NrYl9kc3RfbXR1KHNrYikpDQogMjIzICAgICAgICAgcmV0dXJuIGlw
X2ZpbmlzaF9vdXRwdXQyKHNrYik7DQoNCkNvdWxkIHlvdSBwbGVhc2Ugc3RhdGUgX2NvbmNyZXRl
XyBfcmVhc29uXyB3aHkgbG9jYWxseSBjcmVhdGVkIHNrYiBsZW5ndGggaXMg77y/YWx3YXlz77y/
IGZpdHRpbmcgaW50byBNVFUgc2l6ZT8NCkVzcGVjaWFsbHkgaW4gYmVsb3cgc2NlbmFyaW86DQpo
dHRwOi8vZG9jcy5vcGVuc3RhY2sub3JnL2FkbWluLWd1aWRlLWNsb3VkL2NvbnRlbnQvZmlndXJl
cy8xNC9hL2EvY29tbW9uL2ZpZ3VyZXMvdW5kZXItdGhlLWhvb2Qtc2NlbmFyaW8tMS1vdnMtY29t
cHV0ZS5wbmcNCg0KQXMgbWFueSBwZW9wbGUgaGF2ZSBkaXNjdXNzIGl0IGluIHRoaXMgdGhyZWFk
Og0KaHR0cDovL21hcmMuaW5mby8/dD0xNDE3MTU2Njk3MDAwMDQmcj0xJnc9Mg0KDQoNCg0KDQoN
Cg0KDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYg
bWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9t
YWlsbWFuL2xpc3RpbmZvL2Rldgo=
