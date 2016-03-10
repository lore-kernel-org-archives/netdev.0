From: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH nf-next v9 4/8] openvswitch: Update the CT
 state key only after nf_conntrack_in().
Date: Wed, 9 Mar 2016 18:12:46 -0800
Message-ID: <CAPWQB7GhbtuMUPMLECdv=nkyUL0=hZgdPcKqA73zK_F=jvPKtw@mail.gmail.com>
References: <1457565024-27300-1-git-send-email-jarno@ovn.org>
 <1457565024-27300-4-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarno Rajahalme <jarno-LZ6Gd1LRuIk@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1457565024-27300-4-git-send-email-jarno-LZ6Gd1LRuIk@public.gmane.org>
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

T24gOSBNYXJjaCAyMDE2IGF0IDE1OjEwLCBKYXJubyBSYWphaGFsbWUgPGphcm5vQG92bi5vcmc+
IHdyb3RlOgo+IE9ubHkgYSBzdWNjZXNzZnVsIG5mX2Nvbm50cmFja19pbigpIGNhbGwgY2FuIGVm
ZmVjdCBhIGNvbm5lY3Rpb24gc3RhdGUKPiBjaGFuZ2UsIHNvIGlmIHN1ZmZpY2VzIHRvIHVwZGF0
ZSB0aGUga2V5IG9ubHkgYWZ0ZXIgdGhlCj4gbmZfY29ubnRyYWNrX2luKCkgcmV0dXJucy4KCiJp
dCIgc3VmZmljZXMgdG8gdXBkYXRlLi4uCgo+IFRoaXMgY2hhbmdlIGlzIG5lZWRlZCBmb3IgdGhl
IGxhdGVyIE5BVCBwYXRjaGVzLgo+Cj4gU2lnbmVkLW9mZi1ieTogSmFybm8gUmFqYWhhbG1lIDxq
YXJub0Bvdm4ub3JnPgoKQWNrZWQtYnk6IEpvZSBTdHJpbmdlciA8am9lQG92bi5vcmc+Cl9fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxp
c3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlz
dGluZm8vZGV2Cg==
