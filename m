From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 03/12] net: igb: avoid using timespec
Date: Fri, 2 Oct 2015 09:47:16 +0200
Message-ID: <20151002074716.GA3930@localhost.localdomain>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <1443612402-3000775-4-git-send-email-arnd@arndb.de>
 <20151001191745.GC1872@localhost.localdomain>
 <1803983.ImzkvzgWES@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
Content-Disposition: inline
In-Reply-To: <1803983.ImzkvzgWES@wuerfel>
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

T24gVGh1LCBPY3QgMDEsIDIwMTUgYXQgMTA6MDE6NTdQTSArMDIwMCwgQXJuZCBCZXJnbWFubiB3
cm90ZToKPiBJIHRyaWVkIHRvIHVzZSB0aGlzIHBhdHRlcm4gd2hlbmV2ZXIgSSBjb252ZXJ0IHRo
ZSA2NC1iaXQgJ2xvbmcgbG9uZycKPiB0dl9zZWMgbWVtYmVyIG9mICdzdHJ1Y3QgdGltZXNwZWM2
NCcgaW50byBhIDMyLWJpdCBudW1iZXIsIHRvIGFubm90YXRlCj4gdGhlIGxvc3Mgb2YgcmFuZ2Uu
CgpTb3VuZHMgcmVhc29uYWJsZSB0byBtZS4KIAo+IEkgaGF2ZSB0aG91Z2h0IGFib3V0IGRlZmlu
aW5nIHNlcGFyYXRlIGhlbHBlcnMgbGlrZSB0aGlzCi4uLgo+IFRoaXMgd291bGQgbWFrZSBpdCBl
dmVuIG1vcmUgZXhwbGljaXQsIGJ1dCBteSBmZWFyIHdhcyB0aGF0IEkgd2FzCj4gYWRkaW5nIHRv
byBtdWNoIGNvbXBsZXhpdHkgbGlrZSB0aGF0LgoKSSB0aGluayBhIGNhc3QgcGx1cyBhIGNvbW1l
bnQgd2hlbiBuZWVkZWQgaXMgY2xlYXIgZW5vdWdoLgoKVGhhbmtzLApSaWNoYXJkCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClkyMDM4IG1haWxpbmcgbGlz
dApZMjAzOEBsaXN0cy5saW5hcm8ub3JnCmh0dHBzOi8vbGlzdHMubGluYXJvLm9yZy9tYWlsbWFu
L2xpc3RpbmZvL3kyMDM4Cg==
