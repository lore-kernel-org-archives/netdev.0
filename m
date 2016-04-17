From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Sun, 17 Apr 2016 14:42:33 +0200
Message-ID: <1460896953.15362.2.camel@sipsolutions.net>
References: <20160413060916.GA21184@localhost>
 <1460536706.3057.3.camel@sipsolutions.net> <5521267.mr5HLCdTY6@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, Tina Ruchandani <ruchandani.tina@gmail.com>,
 linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <5521267.mr5HLCdTY6@wuerfel>
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

T24gU3VuLCAyMDE2LTA0LTE3IGF0IDAxOjM0ICswMjAwLCBBcm5kIEJlcmdtYW5uIHdyb3RlOgo+
IE9uIFdlZG5lc2RheSAxMyBBcHJpbCAyMDE2IDEwOjM4OjI2IEpvaGFubmVzIEJlcmcgd3JvdGU6
Cj4gPiAKPiA+ID4gCj4gPiA+IFRoZSBwYXRjaCB3YXMgYnVpbGQtdGVzdGVkIC8gZGVidWdnZWQg
YnkgcmVtb3ZpbmcgdGhlCj4gPiA+ICJpZiBWRVJCT1NFID4gU0hPV19FUlJPUl9NRVNTQUdFUyIg
Z3VhcmRzLgo+ID4gU3RhbmRzIHRvIHJlYXNvbiB0aGF0IHdlIHNob3VsZCBqdXN0IHJlbW92ZSB0
aGUgKG1vcmUgb3IgbGVzcykgZGVhZAo+ID4gY29kZSwgc2luY2UgSSBkb24ndCB0aGluayBhbnlv
bmUgcmVhbGx5IGV2ZXIgdG91Y2hlcyB0aGlzIGRyaXZlcgo+ID4gYW55Cj4gPiBtb3JlIG9yIHdp
bGwgZXZlciBhZ2FpbiAuLi4KPiBEbyB5b3UgbWVhbiByZW1vdmluZyBhbGwgREVCVUcoKSBzdGF0
ZW1lbnRzIGZyb20gdGhlIGRyaXZlciwgb3IKPiByZW1vdmluZyB0aGUgZW50aXJlIGRyaXZlcj8K
PiAKCldlIHRyaWVkIHJlbW92aW5nIHRoZSBkcml2ZXIgb25jZSwgc2luY2UgcDU0IHN1cHBvc2Vk
bHkgZHJpdmVzIHRoZSBzYW1lCmhhcmR3YXJlLCBidXQgc29tZSBwZW9wbGUgaGFkIGNlcnRhaW4g
dXNlIGNhc2VzIHRoYXQgZGlkbid0IHdvcmsgdGhlcmUsCmFwcGFyZW50bHkuCgpJIHdhcyB0aGlu
a2luZyBtb3JlIHJlc3RyaWN0aXZlbHkgb2YganVzdCB0aGUgc3R1ZmYgdGhhdCBjYW4ndCBldmVu
IGJlCmJ1aWx0IHdpdGhvdXQgbW9kaWZ5aW5nIHRoZSBzb3VyY2VzIC0gbGlrZSB0aGUgIiNpZiBW
RVJCT1NFIiB0aGluZy4KCmpvaGFubmVzCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fClkyMDM4IG1haWxpbmcgbGlzdApZMjAzOEBsaXN0cy5saW5hcm8ub3Jn
Cmh0dHBzOi8vbGlzdHMubGluYXJvLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3kyMDM4Cg==
