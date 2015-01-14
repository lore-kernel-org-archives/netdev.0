From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] openvswitch: packet messages need their
 own probe attribtue
Date: Wed, 14 Jan 2015 16:49:58 -0500 (EST)
Message-ID: <20150114.164958.940077874025223530.davem@davemloft.net>
References: <20150114130005.GA564@casper.infradead.org>
 <20150114130351.GB13716@breakpoint.cc>
 <20150114135619.GC564@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
 linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org
To: tgraf-G/eBtMaohhA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20150114135619.GC564-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

RnJvbTogVGhvbWFzIEdyYWYgPHRncmFmQHN1dWcuY2g+CkRhdGU6IFdlZCwgMTQgSmFuIDIwMTUg
MTM6NTY6MTkgKzAwMDAKCj4gVXNlciBzcGFjZSBpcyBjdXJyZW50bHkgc2VuZGluZyBhIE9WU19G
TE9XX0FUVFJfUFJPQkUgZm9yIGJvdGggZmxvdwo+IGFuZCBwYWNrZXQgbWVzc2FnZXMuIFRoaXMg
bGVhZHMgdG8gYW4gb3V0LW9mLWJvdW5kcyBhY2Nlc3MgaW4KPiBvdnNfcGFja2V0X2NtZF9leGVj
dXRlKCkgYmVjYXVzZSBPVlNfRkxPV19BVFRSX1BST0JFID4KPiBPVlNfUEFDS0VUX0FUVFJfTUFY
Lgo+IAo+IEludHJvZHVjZSBhIG5ldyBPVlNfUEFDS0VUX0FUVFJfUFJPQkUgd2l0aCB0aGUgc2Ft
ZSBudW1lcmljIHZhbHVlCj4gYXMgT1ZTX0ZMT1dfQVRUUl9QUk9CRSB0byBncm93IHRoZSByYW5n
ZSBvZiBhY2NlcHRlZCBwYWNrZXQgYXR0cmlidXRlcwo+IHdoaWxlIG1haW50YWluaW5nIHRvIGJl
IGJpbmFyeSBjb21wYXRpYmxlIHdpdGggZXhpc3RpbmcgT1ZTIGJpbmFyaWVzLgo+IAo+IEZpeGVz
OiAwNWRhNTg5ICgib3BlbnZzd2l0Y2g6IEFkZCBzdXBwb3J0IGZvciBPVlNfRkxPV19BVFRSX1BS
T0JFLiIpCj4gUmVwb3J0ZWQtYnk6IFNhbmRlciBFaWtlbGVuYm9vbSA8bGludXhAZWlrZWxlbmJv
b20uaXQ+Cj4gVHJhY2tlZC1kb3duLWJ5OiBGbG9yaWFuIFdlc3RwaGFsIDxmd0BzdHJsZW4uZGU+
Cj4gU2lnbmVkLW9mZi1ieTogVGhvbWFzIEdyYWYgPHRncmFmQHN1dWcuY2g+CgpBcHBsaWVkLCB0
aGFua3MuCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRl
diBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3Jn
L21haWxtYW4vbGlzdGluZm8vZGV2Cg==
