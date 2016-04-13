From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Wed, 13 Apr 2016 11:45:05 +0200
Message-ID: <570E1521.9060602@broadcom.com>
References: <20160413060916.GA21184@localhost>
 <1460536706.3057.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
 Tina Ruchandani <ruchandani.tina@gmail.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1460536706.3057.3.camel@sipsolutions.net>
List-Unsubscribe: <https://lists.linaro.org/mailman/options/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=unsubscribe>
List-Archive: <http://lists.linaro.org/pipermail/y2038/>
List-Post: <mailto:y2038@lists.linaro.org>
List-Help: <mailto:y2038-request@lists.linaro.org?subject=help>
List-Subscribe: <https://lists.linaro.org/mailman/listinfo/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=subscribe>
Errors-To: y2038-bounces@lists.linaro.org
Sender: "Y2038" <y2038-bounces@lists.linaro.org>
List-Id: netdev.vger.kernel.org

T24gMTMtNC0yMDE2IDEwOjM4LCBKb2hhbm5lcyBCZXJnIHdyb3RlOgo+IAo+PiBUaGUgcGF0Y2gg
d2FzIGJ1aWxkLXRlc3RlZCAvIGRlYnVnZ2VkIGJ5IHJlbW92aW5nIHRoZQo+PiAiaWYgVkVSQk9T
RSA+IFNIT1dfRVJST1JfTUVTU0FHRVMiIGd1YXJkcy4KPiAKPiBTdGFuZHMgdG8gcmVhc29uIHRo
YXQgd2Ugc2hvdWxkIGp1c3QgcmVtb3ZlIHRoZSAobW9yZSBvciBsZXNzKSBkZWFkCj4gY29kZSwg
c2luY2UgSSBkb24ndCB0aGluayBhbnlvbmUgcmVhbGx5IGV2ZXIgdG91Y2hlcyB0aGlzIGRyaXZl
ciBhbnkKPiBtb3JlIG9yIHdpbGwgZXZlciBhZ2FpbiAuLi4KCkl0IGRvZXMgYnJpbmcgYmFjayBt
ZW1vcmllcyBmcm9tIG15IEludGVyc2lsL0dsb2Jlc3Bhbi9Db25leGFudCBkYXkocyksCmJ1dCBu
b3Qgc2VudGltZW50YWwgZW5vdWdoIHRvIHRvdWNoIHRoZSBwcmlzbTU0IGRyaXZlci4KCkdyLiBB
dlMKCj4gam9oYW5uZXMKPiAtLQo+IFRvIHVuc3Vic2NyaWJlIGZyb20gdGhpcyBsaXN0OiBzZW5k
IHRoZSBsaW5lICJ1bnN1YnNjcmliZSBsaW51eC13aXJlbGVzcyIgaW4KPiB0aGUgYm9keSBvZiBh
IG1lc3NhZ2UgdG8gbWFqb3Jkb21vQHZnZXIua2VybmVsLm9yZwo+IE1vcmUgbWFqb3Jkb21vIGlu
Zm8gYXQgIGh0dHA6Ly92Z2VyLmtlcm5lbC5vcmcvbWFqb3Jkb21vLWluZm8uaHRtbAo+IApfX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpZMjAzOCBtYWlsaW5n
IGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFyby5vcmcvbWFp
bG1hbi9saXN0aW5mby95MjAzOAo=
