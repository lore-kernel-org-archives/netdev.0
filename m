From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Tue, 19 Apr 2016 10:57:52 +0200
Message-ID: <1461056272.2766.8.camel@sipsolutions.net>
References: <20160413060916.GA21184@localhost> <5521267.mr5HLCdTY6@wuerfel>
 <1460896953.15362.2.camel@sipsolutions.net> <4679823.7bDEQhE9qO@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>, y2038@lists.linaro.org,
 netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 Tina Ruchandani <ruchandani.tina@gmail.com>, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <4679823.7bDEQhE9qO@wuerfel>
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

T24gTW9uLCAyMDE2LTA0LTE4IGF0IDAwOjEwICswMjAwLCBBcm5kIEJlcmdtYW5uIHdyb3RlOgo+
IE9uIFN1bmRheSAxNyBBcHJpbCAyMDE2IDE0OjQyOjMzIEpvaGFubmVzIEJlcmcgd3JvdGU6Cj4g
PiAKPiA+IAo+ID4gSSB3YXMgdGhpbmtpbmcgbW9yZSByZXN0cmljdGl2ZWx5IG9mIGp1c3QgdGhl
IHN0dWZmIHRoYXQgY2FuJ3QgZXZlbgo+ID4gYmUKPiA+IGJ1aWx0IHdpdGhvdXQgbW9kaWZ5aW5n
IHRoZSBzb3VyY2VzIC0gbGlrZSB0aGUgIiNpZiBWRVJCT1NFIiB0aGluZy4KPiBBbGwgdGhlIERF
QlVHKCkgc3RhdGVtZW50cyBhcmUgaW5zaWRlIG9mIHRoaXMga2luZCBvZiBjaGVjaywgc28gaWYg
d2UKPiByZW1vdmUgdGhlICNpZmRlZnMsIGl0IHdvdWxkIGJlIGxvZ2ljYWwgdG8gcmVtb3ZlIHRo
ZSByZXN0IG9mIHRoZQo+IGRlYnVnZ2luZyBpbmZyYXN0cnVjdHVyZSAoREVCVUcoKSBtYWNyb3Ms
IFNIT1dfKiwgcGNfZGVidWcsIG1heWJlCj4gbW9yZSkgYXMgd2VsbC4KPiAKClNlZW1zIHJlYXNv
bmFibGUuCgpNYXliZSB3ZSBzaG91bGQgQ2MgdGhlIG1haW50YWluZXIsIGJ1dCBJIHN1c3BlY3Qg
dGhhdCBzaW5jZSB0aGUgZHJpdmVyCmlzIG1hcmtlZCBPYnNvbGV0ZSBhbnl3YXkgTHVpcyB3b24n
dCBjYXJlIGVpdGhlciA6KQoKam9oYW5uZXMKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KWTIwMzggbWFpbGluZyBsaXN0ClkyMDM4QGxpc3RzLmxpbmFyby5v
cmcKaHR0cHM6Ly9saXN0cy5saW5hcm8ub3JnL21haWxtYW4vbGlzdGluZm8veTIwMzgK
