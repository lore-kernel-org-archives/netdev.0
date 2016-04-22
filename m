From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Fri, 22 Apr 2016 21:09:11 +0300
Message-ID: <87inz9y0qg.fsf@purkki.adurom.net>
References: <20160413060916.GA21184@localhost> <5521267.mr5HLCdTY6@wuerfel>
 <1460896953.15362.2.camel@sipsolutions.net>
 <4679823.7bDEQhE9qO@wuerfel>
 <1461056272.2766.8.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
 y2038@lists.linaro.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 Tina Ruchandani <ruchandani.tina@gmail.com>, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1461056272.2766.8.camel@sipsolutions.net> (Johannes Berg's
 message of "Tue, 19 Apr 2016 10:57:52 +0200")
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

Sm9oYW5uZXMgQmVyZyA8am9oYW5uZXNAc2lwc29sdXRpb25zLm5ldD4gd3JpdGVzOgoKPiBPbiBN
b24sIDIwMTYtMDQtMTggYXQgMDA6MTAgKzAyMDAsIEFybmQgQmVyZ21hbm4gd3JvdGU6Cj4+IE9u
IFN1bmRheSAxNyBBcHJpbCAyMDE2IDE0OjQyOjMzIEpvaGFubmVzIEJlcmcgd3JvdGU6Cj4+ID4g
Cj4+ID4gSSB3YXMgdGhpbmtpbmcgbW9yZSByZXN0cmljdGl2ZWx5IG9mIGp1c3QgdGhlIHN0dWZm
IHRoYXQgY2FuJ3QgZXZlbgo+PiA+IGJlIGJ1aWx0IHdpdGhvdXQgbW9kaWZ5aW5nIHRoZSBzb3Vy
Y2VzIC0gbGlrZSB0aGUgIiNpZiBWRVJCT1NFIgo+PiA+IHRoaW5nLgo+Pgo+PiBBbGwgdGhlIERF
QlVHKCkgc3RhdGVtZW50cyBhcmUgaW5zaWRlIG9mIHRoaXMga2luZCBvZiBjaGVjaywgc28gaWYg
d2UKPj4gcmVtb3ZlIHRoZSAjaWZkZWZzLCBpdCB3b3VsZCBiZSBsb2dpY2FsIHRvIHJlbW92ZSB0
aGUgcmVzdCBvZiB0aGUKPj4gZGVidWdnaW5nIGluZnJhc3RydWN0dXJlIChERUJVRygpIG1hY3Jv
cywgU0hPV18qLCBwY19kZWJ1ZywgbWF5YmUKPj4gbW9yZSkgYXMgd2VsbC4KPgo+IFNlZW1zIHJl
YXNvbmFibGUuCj4KPiBNYXliZSB3ZSBzaG91bGQgQ2MgdGhlIG1haW50YWluZXIsIGJ1dCBJIHN1
c3BlY3QgdGhhdCBzaW5jZSB0aGUgZHJpdmVyCj4gaXMgbWFya2VkIE9ic29sZXRlIGFueXdheSBM
dWlzIHdvbid0IGNhcmUgZWl0aGVyIDopCgpJJ20gcGxhbm5pbmcgdG8gYXBwbHkgdGhpcyBwYXRj
aCBhbnl3YXksIHRoZSBkZWJ1Z2dpbmcgaW5mcmFzdHJ1Y3R1cmUKcmVtb3ZhbCBjYW4gYmUgYSBm
b2xsb3d1cCBwYXRjaC4gQnV0IHBsZWFzZSBsZXQgbWUga25vdyBpZiBJIHNob3VsZCBkcm9wCnRo
aXMgaW5zdGVhZC4KCi0tIApLYWxsZSBWYWxvCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fClkyMDM4IG1haWxpbmcgbGlzdApZMjAzOEBsaXN0cy5saW5hcm8u
b3JnCmh0dHBzOi8vbGlzdHMubGluYXJvLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3kyMDM4Cg==
