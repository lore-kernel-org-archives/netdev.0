From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 10/10] staging: vt6656: inherit addr_assign_type
 along with dev_addr
Date: Fri, 23 Aug 2013 12:48:17 +0200
Message-ID: <87y57s3cpa.fsf@nemi.mork.no>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
 <1377250513-3662-11-git-send-email-bjorn@mork.no>
 <20130823100333.GT22811@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Forest Bond <forest@alittletooquiet.net>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20130823100333.GT22811@mwanda> (Dan Carpenter's message of "Fri,
 23 Aug 2013 13:03:33 +0300")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

RGFuIENhcnBlbnRlciA8ZGFuLmNhcnBlbnRlckBvcmFjbGUuY29tPiB3cml0ZXM6Cgo+IE9uIEZy
aSwgQXVnIDIzLCAyMDEzIGF0IDExOjM1OjEzQU0gKzAyMDAsIEJqw7hybiBNb3JrIHdyb3RlOgo+
PiBDYzogRm9yZXN0IEJvbmQgPGZvcmVzdEBhbGl0dGxldG9vcXVpZXQubmV0Pgo+PiBTaWduZWQt
b2ZmLWJ5OiBCasO4cm4gTW9yayA8Ympvcm5AbW9yay5ubz4KPj4gLS0tCj4KPiBUaGUgY2hhbmds
b2cgaXMgbWlzc2luZy4KClllcywgcmlnaHQuICBTb3JyeSBhYm91dCB0aGF0LgoKPiAgV2h5IGRv
ZXMgdGhpcyBwYXRjaCBoZWxwPwoKSXQgZW5zdXJlcyB0aGF0IGFkZHJfYXNzaWduX3R5cGUgaXMg
c2V0IHRvIHRoZSBzYW1lIHZhbHVlIGFzIHRoZSBwYXJlbnQKZGV2aWNlIHRoZSBkZXZfYWRkciBp
cyBjb3BpZWQgZnJvbS4gIFRoZSBpbml0aWFsIHJlYXNvbiB3YXMgdGhhdCBJIGZvdW5kCml0IHN0
cmFuZ2UgdG8gc2VlIE5FVF9BRERSX1BFUk0gb24gYSB2bGFuIGRldmljZSB3aGljaCBoYWQgaW5o
ZXJpdGVkIGEKcmFuZG9tIGFkZHJlc3MgZnJvbSBpdHMgcGFyZW50LgoKQnV0IEkgaGF2ZW4ndCB2
ZXJpZmllZCB3aGV0aGVyIHRoYXQgdGhlIHBhcmVudCBkZXZpY2UgYWN0dWFsbHkgY2FuIGhhdmUK
YW4gYWRkcl9hc3NpZ25fdHlwZSAhPSBORVRfQUREUl9QRVJNIGZvciBldmVyeSBkcml2ZXIgaW5j
bHVkZWQuIAoKCkJqw7hybgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KZGV2ZWwgbWFpbGluZyBsaXN0CmRldmVsQGxpbnV4ZHJpdmVycHJvamVjdC5vcmcK
aHR0cDovL2RyaXZlcmRldi5saW51eGRyaXZlcnByb2plY3Qub3JnL21haWxtYW4vbGlzdGluZm8v
ZHJpdmVyZGV2LWRldmVsCg==
