From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Sun, 17 Apr 2016 01:34:33 +0200
Message-ID: <5521267.mr5HLCdTY6@wuerfel>
References: <20160413060916.GA21184@localhost>
 <1460536706.3057.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, Tina Ruchandani <ruchandani.tina@gmail.com>,
 linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
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

T24gV2VkbmVzZGF5IDEzIEFwcmlsIDIwMTYgMTA6Mzg6MjYgSm9oYW5uZXMgQmVyZyB3cm90ZToK
PiA+IFRoZSBwYXRjaCB3YXMgYnVpbGQtdGVzdGVkIC8gZGVidWdnZWQgYnkgcmVtb3ZpbmcgdGhl
Cj4gPiAiaWYgVkVSQk9TRSA+IFNIT1dfRVJST1JfTUVTU0FHRVMiIGd1YXJkcy4KPiAKPiBTdGFu
ZHMgdG8gcmVhc29uIHRoYXQgd2Ugc2hvdWxkIGp1c3QgcmVtb3ZlIHRoZSAobW9yZSBvciBsZXNz
KSBkZWFkCj4gY29kZSwgc2luY2UgSSBkb24ndCB0aGluayBhbnlvbmUgcmVhbGx5IGV2ZXIgdG91
Y2hlcyB0aGlzIGRyaXZlciBhbnkKPiBtb3JlIG9yIHdpbGwgZXZlciBhZ2FpbiAuLi4KCkRvIHlv
dSBtZWFuIHJlbW92aW5nIGFsbCBERUJVRygpIHN0YXRlbWVudHMgZnJvbSB0aGUgZHJpdmVyLCBv
cgpyZW1vdmluZyB0aGUgZW50aXJlIGRyaXZlcj8KCglBcm5kCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fClkyMDM4IG1haWxpbmcgbGlzdApZMjAzOEBsaXN0
cy5saW5hcm8ub3JnCmh0dHBzOi8vbGlzdHMubGluYXJvLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3ky
MDM4Cg==
