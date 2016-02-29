From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 1/3] net: ipv4: Convert IP network timestamps
	to be y2038 safe
Date: Mon, 29 Feb 2016 17:31:11 +0100
Message-ID: <7222364.EzaDaAUEpl@wuerfel>
References: <1456561938-7653-1-git-send-email-deepa.kernel@gmail.com>
 <1456561938-7653-2-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
 James Morris <jmorris@namei.org>, Patrick McHardy <kaber@trash.net>,
 Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 "David S. Miller" <davem@davemloft.net>
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1456561938-7653-2-git-send-email-deepa.kernel@gmail.com>
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

T24gU2F0dXJkYXkgMjcgRmVicnVhcnkgMjAxNiAwMDozMjoxNSBEZWVwYSBEaW5hbWFuaSB3cm90
ZToKPiBJQ01QIHRpbWVzdGFtcCBtZXNzYWdlcyBhbmQgSVAgc291cmNlIHJvdXRlIG9wdGlvbnMg
cmVxdWlyZQo+IHRpbWVzdGFtcHMgdG8gYmUgaW4gbWlsbGlzZWNvbmRzIG1vZHVsbyAyNCBob3Vy
cyBmcm9tCj4gbWlkbmlnaHQgVVQgZm9ybWF0Lgo+IAo+IEFkZCBpbmV0X2N1cnJlbnRfdGltZXN0
YW1wKCkgZnVuY3Rpb24gdG8gc3VwcG9ydCB0aGlzLiBUaGUgZnVuY3Rpb24KPiByZXR1cm5zIHRo
ZSByZXF1aXJlZCB0aW1lc3RhbXAgaW4gbmV0d29yayBieXRlIG9yZGVyLgo+IAo+IFRpbWVzdGFt
cCBjYWxjdWxhdGlvbiBpcyBhbHNvIGNoYW5nZWQgdG8gY2FsbCBrdGltZV9nZXRfcmVhbF90czY0
KCkKPiB3aGljaCB1c2VzIHN0cnVjdCB0aW1lc3BlYzY0LiBzdHJ1Y3QgdGltZXNwZWM2NCBpcyB5
MjAzOCBzYWZlLgo+IFByZXZpb3VzbHkgaXQgY2FsbGVkIGdldG5zdGltZW9mZGF5KCkgd2hpY2gg
dXNlcyBzdHJ1Y3QgdGltZXNwZWMuCj4gc3RydWN0IHRpbWVzcGVjIGlzIG5vdCB5MjAzOCBzYWZl
Lgo+IAo+IFNpZ25lZC1vZmYtYnk6IERlZXBhIERpbmFtYW5pIDxkZWVwYS5rZXJuZWxAZ21haWwu
Y29tPgo+IENjOiAiRGF2aWQgUy4gTWlsbGVyIiA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4KPiBDYzog
QWxleGV5IEt1em5ldHNvdiA8a3V6bmV0QG1zMi5pbnIuYWMucnU+Cj4gQ2M6IEhpZGVha2kgWU9T
SElGVUpJIDx5b3NoZnVqaUBsaW51eC1pcHY2Lm9yZz4KPiBDYzogSmFtZXMgTW9ycmlzIDxqbW9y
cmlzQG5hbWVpLm9yZz4KPiBDYzogUGF0cmljayBNY0hhcmR5IDxrYWJlckB0cmFzaC5uZXQ+Cj4g
CgpBY2tlZC1ieTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4KX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KWTIwMzggbWFpbGluZyBsaXN0ClkyMDM4
QGxpc3RzLmxpbmFyby5vcmcKaHR0cHM6Ly9saXN0cy5saW5hcm8ub3JnL21haWxtYW4vbGlzdGlu
Zm8veTIwMzgK
