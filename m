From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 00/25] Convert the posix_clock_operations and
 k_clock structure to ready for 2038
Date: Tue, 2 Jun 2015 21:19:17 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1506021719290.20347@nanos>
References: <1433159093-4548-1-git-send-email-baolin.wang@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: pang.xunlei@linaro.org, peterz@infradead.org, benh@kernel.crashing.org,
 heiko.carstens@de.ibm.com, paulus@samba.org, jeffv@google.com, cl@linux.com,
 mark.d.rustad@intel.com, heenasirwani@gmail.com, linux-arch@vger.kernel.org,
 linux-s390@vger.kernel.org, y2038@lists.linaro.org, mpe@ellerman.id.au,
 rafael.j.wysocki@intel.com, ahh@google.com, tiwai@suse.de,
 jlayton@primarydata.com, fweisbec@gmail.com, pjt@google.com, serge@hallyn.com,
 serge.hallyn@canonical.com, riel@redhat.com, keescook@chromium.org,
 arnd@arndb.de, richardcochran@gmail.com, schwidefsky@de.ibm.com,
 john.stultz@linaro.org, james.l.morris@oracle.com, rth@twiddle.net,
 sds@tycho.nsa.gov, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 pmoore@redhat.com, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, tj@kernel.org, linux390@de.ibm.com,
 linuxppc-dev@lists.ozlabs.org
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1433159093-4548-1-git-send-email-baolin.wang@linaro.org>
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

T24gTW9uLCAxIEp1biAyMDE1LCBCYW9saW4gV2FuZyB3cm90ZToKCllvdSBmYWlsZWQgdG8gdGhy
ZWFkIHRoZSBwYXRjaCBzZXJpZXMgYWdhaW4gLi4uLgpfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwpZMjAzOCBtYWlsaW5nIGxpc3QKWTIwMzhAbGlzdHMubGlu
YXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFyby5vcmcvbWFpbG1hbi9saXN0aW5mby95MjAzOAo=
