From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] isdn: Use ktime_t instead of 'struct timeval'
Date: Sun, 20 Mar 2016 16:47:28 -0400 (EDT)
Message-ID: <20160320.164728.395636107297003956.davem@davemloft.net>
References: <20160319182113.GA2256@tina-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org, isdn@linux-pingi.de,
 linux-kernel@vger.kernel.org, arnd@arndb.de
To: ruchandani.tina@gmail.com
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <20160319182113.GA2256@tina-laptop>
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

RnJvbTogVGluYSBSdWNoYW5kYW5pIDxydWNoYW5kYW5pLnRpbmFAZ21haWwuY29tPgpEYXRlOiBT
YXQsIDE5IE1hciAyMDE2IDExOjIxOjE0IC0wNzAwCgo+ICdzdHJ1Y3QgdGltZXZhbCcgdXNlcyAz
Mi1iaXQgcmVwcmVzZW50YXRpb24gZm9yIHNlY29uZHMgd2hpY2ggd2lsbAo+IG92ZXJmbG93IGlu
IHllYXIgMjAzOCBhbmQgYmV5b25kLiBtSVNETi9jbG9jay5jIG5lZWRzIHRvIGNvbXB1dGUgYW5k
Cj4gc3RvcmUgZWxhcHNlZCB0aW1lIGluIGludGVydmFscyBvZiAxMjUgbWljcm9zZWNvbmRzLiBU
aGlzIHBhdGNoIHJlcGxhY2VzCj4gdGhlIHVzYWdlIG9mICdzdHJ1Y3QgdGltZXZhbCcgd2l0aCA2
NC1iaXQga3RpbWVfdCB3aGljaCBpcyB5MjAzOCBzYWZlLgo+IFRoZSBwYXRjaCBhbHNvIHJlcGxh
Y2VzIGRvX2dldHRpbWVvZmRheSgpICh3YWxsLWNsb2NrIHRpbWUpIHdpdGgKPiBrdGltZV9nZXQo
KSAobW9ub3RvbmljIHRpbWUpIHNpbmNlIHdlIG9ubHkgY2FyZSBhYm91dCBlbGFwc2VkIHRpbWUg
aGVyZS4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBUaW5hIFJ1Y2hhbmRhbmkgPHJ1Y2hhbmRhbmkudGlu
YUBnbWFpbC5jb20+Cj4gU3VnZ2VzdGVkLWJ5OiBBcm5kIEJlcmdtbmFubiA8YXJuZEBhcm5kYi5k
ZT4KPiBTdWdnZXN0ZWQtYnk6IERhdmlkIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4KCkFw
cGxpZWQsIHRoYW5rIHlvdS4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KWTIwMzggbWFpbGluZyBsaXN0ClkyMDM4QGxpc3RzLmxpbmFyby5vcmcKaHR0cHM6
Ly9saXN0cy5saW5hcm8ub3JnL21haWxtYW4vbGlzdGluZm8veTIwMzgK
