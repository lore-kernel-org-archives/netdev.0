From: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH v2 net-next] ovs: allow nl 'flow set' to use
 ufid without flow key
Date: Fri, 11 Mar 2016 10:35:55 +0900
Message-ID: <20160311013552.GA25270@penelope.isobedori.kobe.vergenet.net>
References: <CAMEOZhK0kBpdS8uOqYqzQs+6LyWh5K3MWL__CRoThmNRnBN2MQ@mail.gmail.com>
 <1457626499-26585-1-git-send-email-samuel.gauthier@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Samuel Gauthier <samuel.gauthier-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1457626499-26585-1-git-send-email-samuel.gauthier-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

T24gVGh1LCBNYXIgMTAsIDIwMTYgYXQgMDU6MTQ6NTlQTSArMDEwMCwgU2FtdWVsIEdhdXRoaWVy
IHdyb3RlOgo+IFdoZW4gd2Ugd2FudCB0byBjaGFuZ2UgYSBmbG93IHVzaW5nIG5ldGxpbmssIHdl
IGhhdmUgdG8gaWRlbnRpZnkgaXQgdG8KPiBiZSBhYmxlIHRvIHBlcmZvcm0gYSBsb29rdXAuIEJv
dGggdGhlIGZsb3cga2V5IGFuZCB1bmlxdWUgZmxvdyBJRAo+ICh1ZmlkKSBhcmUgdmFsaWQgaWRl
bnRpZmllcnMsIGJ1dCB3ZSBhbHdheXMgaGF2ZSB0byBzcGVjaWZ5IHRoZSBmbG93Cj4ga2V5IGlu
IHRoZSBuZXRsaW5rIG1lc3NhZ2UuIFdoZW4gYm90aCBhdHRyaWJ1dGVzIGFyZSB0aGVyZSwgdGhl
IHVmaWQKPiBpcyB1c2VkLiBUaGUgZmxvdyBrZXkgaXMgdXNlZCB0byB2YWxpZGF0ZSB0aGUgYWN0
aW9ucyBwcm92aWRlZCBieQo+IHRoZSB1c2VybGFuZC4KPiAKPiBUaGlzIGNvbW1pdCBhbGxvd3Mg
dG8gdXNlIHRoZSB1ZmlkIHdpdGhvdXQgaGF2aW5nIHRvIHByb3ZpZGUgdGhlIGZsb3cKPiBrZXks
IGFzIGl0IGlzIGFscmVhZHkgZG9uZSBpbiB0aGUgbmV0bGluayAnZmxvdyBnZXQnIGFuZCAnZmxv
dyBkZWwnCj4gcGF0aC4gVGhlIGZsb3cga2V5IHJlbWFpbnMgbWFuZGF0b3J5IHdoZW4gYW4gYWN0
aW9uIGlzIHByb3ZpZGVkLgo+IAo+IFNpZ25lZC1vZmYtYnk6IFNhbXVlbCBHYXV0aGllciA8c2Ft
dWVsLmdhdXRoaWVyQDZ3aW5kLmNvbT4KClJldmlld2VkLWJ5OiBTaW1vbiBIb3JtYW4gPHNpbW9u
Lmhvcm1hbkBuZXRyb25vbWUuY29tPgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDov
L29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
