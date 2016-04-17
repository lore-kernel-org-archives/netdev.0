From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Mon, 18 Apr 2016 00:10:48 +0200
Message-ID: <4679823.7bDEQhE9qO@wuerfel>
References: <20160413060916.GA21184@localhost> <5521267.mr5HLCdTY6@wuerfel>
 <1460896953.15362.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, Tina Ruchandani <ruchandani.tina@gmail.com>,
 linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1460896953.15362.2.camel@sipsolutions.net>
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

T24gU3VuZGF5IDE3IEFwcmlsIDIwMTYgMTQ6NDI6MzMgSm9oYW5uZXMgQmVyZyB3cm90ZToKPiAK
PiBJIHdhcyB0aGlua2luZyBtb3JlIHJlc3RyaWN0aXZlbHkgb2YganVzdCB0aGUgc3R1ZmYgdGhh
dCBjYW4ndCBldmVuIGJlCj4gYnVpbHQgd2l0aG91dCBtb2RpZnlpbmcgdGhlIHNvdXJjZXMgLSBs
aWtlIHRoZSAiI2lmIFZFUkJPU0UiIHRoaW5nLgoKQWxsIHRoZSBERUJVRygpIHN0YXRlbWVudHMg
YXJlIGluc2lkZSBvZiB0aGlzIGtpbmQgb2YgY2hlY2ssIHNvIGlmIHdlCnJlbW92ZSB0aGUgI2lm
ZGVmcywgaXQgd291bGQgYmUgbG9naWNhbCB0byByZW1vdmUgdGhlIHJlc3Qgb2YgdGhlIGRlYnVn
Z2luZwppbmZyYXN0cnVjdHVyZSAoREVCVUcoKSBtYWNyb3MsIFNIT1dfKiwgcGNfZGVidWcsIG1h
eWJlIG1vcmUpIGFzIHdlbGwuCgoJQXJuZApfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpZMjAzOCBtYWlsaW5nIGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9y
ZwpodHRwczovL2xpc3RzLmxpbmFyby5vcmcvbWFpbG1hbi9saXN0aW5mby95MjAzOAo=
