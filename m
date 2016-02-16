From: Jesse Gross <jesse-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net] geneve: Refine MTU limit
Date: Tue, 16 Feb 2016 10:32:15 -0800
Message-ID: <CAEh+42i628VNoXh5=vtFKzqVGeF4NqY3=GKbdNVeqmYnWK_oBg@mail.gmail.com>
References: <1455625999-9781-1-git-send-email-david@weave.works>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
To: David Wragg <david-1SEAoVOfG6VEzL6FDj/jAg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1455625999-9781-1-git-send-email-david-1SEAoVOfG6VEzL6FDj/jAg@public.gmane.org>
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

T24gVHVlLCBGZWIgMTYsIDIwMTYgYXQgNDozMyBBTSwgRGF2aWQgV3JhZ2cgPGRhdmlkQHdlYXZl
LndvcmtzPiB3cm90ZToKPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZ2VuZXZlLmMgYi9kcml2
ZXJzL25ldC9nZW5ldmUuYwo+IGluZGV4IDAyOGUzODcuLmY1N2Y5YmMgMTAwNjQ0Cj4gLS0tIGEv
ZHJpdmVycy9uZXQvZ2VuZXZlLmMKPiArKysgYi9kcml2ZXJzL25ldC9nZW5ldmUuYwo+IEBAIC0z
Nyw2ICszNyw5IEBAIE1PRFVMRV9QQVJNX0RFU0MobG9nX2Vjbl9lcnJvciwgIkxvZyBwYWNrZXRz
IHJlY2VpdmVkIHdpdGggY29ycnVwdGVkIEVDTiIpOwo+Cj4gICNkZWZpbmUgR0VORVZFX1ZFUiAw
Cj4gICNkZWZpbmUgR0VORVZFX0JBU0VfSExFTiAoc2l6ZW9mKHN0cnVjdCB1ZHBoZHIpICsgc2l6
ZW9mKHN0cnVjdCBnZW5ldmVoZHIpKQo+ICsjZGVmaW5lIEdFTkVWRV9NQVhfT1BUSU9OU19MRU4g
KDYzICogNCkKPiArI2RlZmluZSBHRU5FVkVfTUFYX01UVSAoSVBfTUFYX01UVSAtIHNpemVvZihz
dHJ1Y3QgaXBoZHIpIC0gR0VORVZFX0JBU0VfSExFTiBcCj4gKyAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgLSBHRU5FVkVfTUFYX09QVElPTlNfTEVOKQoKSW4g
YWRkaXRpb24gdG8gVG9tJ3MgY29tbWVudCBhYm91dCB0YWtpbmcgaW50byBhY2NvdW50CmRldi0+
aGFyZF9oZWFkZXJfbGVuLCBjYW4geW91IHBsZWFzZSBub3QgaW5jbHVkZQpHRU5FVkVfTUFYX09Q
VElPTlNfTEVOIGluIHRoZSBNVFUgY2FsY3VsYXRpb24gYmFzZWQgb24gdGhlIGRpc2N1c3Npb24K
b24gdGhlIG90aGVyIHRocmVhZD8gT3RoZXJ3aXNlLCB5b3UgYXJlIGV4Y2x1ZGluZyBzb21lIHBv
dGVudGlhbGx5CnZhbGlkIGNvbmZpZ3VyYXRpb25zLgpfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5v
cmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
