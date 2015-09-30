From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 3/5] ntp: use timespec64 in sync_cmos_clock
Date: Wed, 30 Sep 2015 09:22:20 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509300920560.4500@nanos>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
 <1443471692-2946597-4-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Rodolfo Giometti <giometti@enneenne.com>, y2038@lists.linaro.org,
 netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
 linux-kernel@vger.kernel.org, linux-net-drivers@solarflare.com,
 John Stultz <john.stultz@linaro.org>, Shradha Shah <sshah@solarflare.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1443471692-2946597-4-git-send-email-arnd@arndb.de>
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

T24gTW9uLCAyOCBTZXAgMjAxNSwgQXJuZCBCZXJnbWFubiB3cm90ZToKPiBUaGUgc3luY19jbW9z
X2Nsb2NrIGhhcyBvbmUgdXNlIG9mIHN0cnVjdCB0aW1lc3BlYywgd2hpY2ggd2Ugd2FudCB0bwo+
IGV2ZW50dWFsbHkgcmVwbGFjZSB3aXRoIHRpbWVzcGVjNjQgb3Igc2ltaWxhciBpbiB0aGUga2Vy
bmVsLiBUaGVyZQo+IGlzIG5vIHdheSB0aGlzIG9uZSBjYW4gb3ZlcmZsb3csIGJ1dCB0aGUgY29u
dmVyc2lvbiB0byB0aW1lc3BlYzY0Cj4gaXMgdHJpdmlhbCBhbmQgaGFzIG5vIG90aGVyIGRlcGVu
ZGVuY2llcy4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRl
PgoKUmV2aWV3ZWQtYnk6IFRob21hcyBHbGVpeG5lciA8dGdseEBsaW51dHJvbml4LmRlPgpfX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpZMjAzOCBtYWlsaW5n
IGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFyby5vcmcvbWFp
bG1hbi9saXN0aW5mby95MjAzOAo=
