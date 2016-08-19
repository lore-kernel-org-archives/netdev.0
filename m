From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH] openvswitch: use percpu flow stats
Date: Fri, 19 Aug 2016 12:56:56 -0700
Message-ID: <1471636616.29842.110.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471636046-9246-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thadeu Lima de Souza Cascardo <cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1471636046-9246-1-git-send-email-cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

T24gRnJpLCAyMDE2LTA4LTE5IGF0IDE2OjQ3IC0wMzAwLCBUaGFkZXUgTGltYSBkZSBTb3V6YSBD
YXNjYXJkbyB3cm90ZToKPiBJbnN0ZWFkIG9mIHVzaW5nIGZsb3cgc3RhdHMgcGVyIE5VTUEgbm9k
ZSwgdXNlIGl0IHBlciBDUFUuIFdoZW4gdXNpbmcKPiBtZWdhZmxvd3MsIHRoZSBzdGF0cyBsb2Nr
IGNhbiBiZSBhIGJvdHRsZW5lY2sgaW4gc2NhbGFiaWxpdHkuCgouLi4KCj4gIAo+ICAJZmxvd19j
YWNoZSA9IGttZW1fY2FjaGVfY3JlYXRlKCJzd19mbG93Iiwgc2l6ZW9mKHN0cnVjdCBzd19mbG93
KQo+IC0JCQkJICAgICAgICsgKG5yX25vZGVfaWRzCj4gKwkJCQkgICAgICAgKyAobnVtX3Bvc3Np
YmxlX2NwdXMoKQo+ICAJCQkJCSAgKiBzaXplb2Yoc3RydWN0IGZsb3dfc3RhdHMgKikpLAo+ICAJ
CQkJICAgICAgIDAsIDAsIE5VTEwpOwo+ICAJaWYgKGZsb3dfY2FjaGUgPT0gTlVMTCkKClRoaXMg
aXMgYm9ndXMuCgpQbGVhc2UgdXNlIG5yX2NwdV9pZHMgaW5zdGVhZCBvZiBudW1fcG9zc2libGVf
Y3B1cygpLgoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNo
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
