From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH net-next V11 2/3] Check for vlan ethernet
 types for 8021.q or 802.1ad
Date: Tue, 23 Jun 2015 21:43:20 +0300
Message-ID: <5589A8C8.6080702@cogentembedded.com>
References: <1435083990-12986-1-git-send-email-thomasfherbert@gmail.com>
 <1435083990-12986-3-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, therbert-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Thomas F Herbert <thomasfherbert-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1435083990-12986-3-git-send-email-thomasfherbert-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

SGVsbG8uCgpPbiAwNi8yMy8yMDE1IDA5OjI2IFBNLCBUaG9tYXMgRiBIZXJiZXJ0IHdyb3RlOgoK
PiBTaWduZWQtb2ZmLWJ5OiBUaG9tYXMgRiBIZXJiZXJ0IDx0aG9tYXNmaGVyYmVydEBnbWFpbC5j
b20+ClsuLi5dCgo+IGRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L2lmX3ZsYW4uaCBiL2luY2x1
ZGUvbGludXgvaWZfdmxhbi5oCj4gaW5kZXggOTIwZTQ0NS4uMzcxMzQ1NCAxMDA2NDQKPiAtLS0g
YS9pbmNsdWRlL2xpbnV4L2lmX3ZsYW4uaAo+ICsrKyBiL2luY2x1ZGUvbGludXgvaWZfdmxhbi5o
Cj4gQEAgLTYyNyw1ICs2MjcsMTQgQEAgc3RhdGljIGlubGluZSBuZXRkZXZfZmVhdHVyZXNfdCB2
bGFuX2ZlYXR1cmVzX2NoZWNrKGNvbnN0IHN0cnVjdCBza19idWZmICpza2IsCj4KPiAgIAlyZXR1
cm4gZmVhdHVyZXM7Cj4gICB9Cj4gKy8qKgo+ICsgKiBDaGVjayBmb3IgbGVnYWwgdmFsaWQgdmxh
biBldGhlciB0eXBlLgoKICAgIFRoZSBjb21tZW50IGRvZXNuJ3QgZm9sbG93IHRoZSBrZXJuZWwt
ZG9jIGZvcm1hdCBkZXRlcm1pbmVkIGJ5IC8qKi4KCj4gKyAqLwo+ICtzdGF0aWMgaW5saW5lIGJv
b2wgZXRoX3R5cGVfdmxhbihfX2JlMTYgZXRoZXJ0eXBlKQo+ICt7Cj4gKwlpZiAoZXRoZXJ0eXBl
ID09IGh0b25zKEVUSF9QXzgwMjFRKSB8fCBldGhlcnR5cGUgPT0gaHRvbnMoRVRIX1BfODAyMUFE
KSkKPiArCQlyZXR1cm4gdHJ1ZTsKPiArCXJldHVybiBmYWxzZTsKCiAgICBQZXJoYXBzICpzd2l0
Y2gqPwoKWy4uLl0KCldCUiwgU2VyZ2VpCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0
cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
