From: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Subject: Re: [RFC net-next 11/22] dst: Metadata destinations
Date: Fri, 10 Jul 2015 21:57:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507102139530.1754@ja.home.ssi.bg>
References: <cover.1436537414.git.tgraf@suug.ch>
 <1b20319e1ff0f2be28e783b90ac48738d6a8b72b.1436537414.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
 daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
 rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1b20319e1ff0f2be28e783b90ac48738d6a8b72b.1436537414.git.tgraf-G/eBtMaohhA@public.gmane.org>
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

CglIZWxsbywKCk9uIEZyaSwgMTAgSnVsIDIwMTUsIFRob21hcyBHcmFmIHdyb3RlOgoKPiAtLS0g
YS9uZXQvaXB2NC9yb3V0ZS5jCj4gKysrIGIvbmV0L2lwdjQvcm91dGUuYwo+IEBAIC0xNjkxLDYg
KzE2OTEsOCBAQCBzdGF0aWMgaW50IGlwX3JvdXRlX2lucHV0X3Nsb3coc3RydWN0IHNrX2J1ZmYg
KnNrYiwgX19iZTMyIGRhZGRyLCBfX2JlMzIgc2FkZHIsCj4gIAkgICBieSBmaWJfbG9va3VwLgo+
ICAJICovCj4gIAo+ICsJc2tiX2RzdF9kcm9wKHNrYik7Cj4gKwoKCVRoaXMgaXMgbm90IHZlcnkg
c2FmZS4gVGhlcmUgYXJlIHBsYWNlcyB0aGF0CmNhbGwgaXBfcm91dGVfaW5wdXQoKSBmb3IgdGVt
cG9yYXJ5IGxvb2t1cHMgYW5kIHRoZXkKZG8gbm90IHNldCBOVUxMLiBGb3IgZXhhbXBsZSwgaWNt
cF9yb3V0ZV9sb29rdXAoKSwKbWF5IGJlIHRoZXJlIGFyZSBvdGhlciBzdWNoIHBsYWNlcy4uLgoK
CU9UT0gsIGlwX29wdGlvbnNfcmN2X3NycigpIGxvb2tzIGNvcnJlY3QgdG8gdXNlCnNrYl9kc3Rf
c2V0KHNrYiwgTlVMTCksIG1heSBiZSBzdWNoIGNhbGwgc2hvdWxkIGJlCmFkZGVkIGlmIGl0IGlz
IG1pc3NpbmcuLi4KCj4gIAlpZiAoaXB2NF9pc19tdWx0aWNhc3Qoc2FkZHIpIHx8IGlwdjRfaXNf
bGJjYXN0KHNhZGRyKSkKPiAgCQlnb3RvIG1hcnRpYW5fc291cmNlOwoKUmVnYXJkcwoKLS0KSnVs
aWFuIEFuYXN0YXNvdiA8amFAc3NpLmJnPgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0
cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
