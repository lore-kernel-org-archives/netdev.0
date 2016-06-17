From: Chris Metcalf <cmetcalf@mellanox.com>
Subject: Re: [PATCH] net: tilegx: use correct timespec64 type
Date: Fri, 17 Jun 2016 12:18:46 -0400
Message-ID: <7dfd1442-c812-d7a2-ced2-96970469227b@mellanox.com>
References: <20160617161540.1362545-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
 Richard Cochran <richardcochran@gmail.com>, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <20160617161540.1362545-1-arnd@arndb.de>
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

T24gNi8xNy8yMDE2IDEyOjE1IFBNLCBBcm5kIEJlcmdtYW5uIHdyb3RlOgo+IFRoZSBjb252ZXJz
aW9uIHRvIHRoZSA2NC1iaXQgdGltZSBiYXNlZCBwdHAgbWV0aG9kcyBsZWZ0IHR3byBpbnN0YW5j
ZXMKPiBvZiAnc3RydWN0IHRpbWVzcGVjJyBpbiBwbGFjZS4gVGhpcyBpcyBoYXJtbGVzcyBiZWNh
dXNlIDY0LWJpdAo+IGFyY2hpdGVjdHVyZXMgZGVmaW5lIHRpbWVzcGVjNjQgYXMgdGltZXNwZWMs
IGFuZCB0aGlzIGRyaXZlciBpcwo+IG5vdCB1c2VkIG9uIDMyLWJpdCBtYWNoaW5lcy4KPgo+IEhv
d2V2ZXIsIHVzaW5nICdzdHJ1Y3QgdGltZXNwZWM2NCcgZGlyZWN0bHkgaXMgb2J2aW91c2x5IHRo
ZSByaWdodAo+IHRoaW5nIHRvIGRvLCBhbmQgd2lsbCBoZWxwIHVzIHJlbW92ZSAnc3RydWN0IHRp
bWVzcGVjJyBpbiB0aGUgZnV0dXJlLgo+Cj4gU2lnbmVkLW9mZi1ieTogQXJuZCBCZXJnbWFubjxh
cm5kQGFybmRiLmRlPgo+IEZpeGVzOiBiOWFjZjI0Zjc3OWMgKCJwdHA6IHRpbGVneDogY29udmVy
dCB0byB0aGUgNjQgYml0IGdldC9zZXQgdGltZSBtZXRob2RzLiIpCj4gLS0tCj4gICBkcml2ZXJz
L25ldC9ldGhlcm5ldC90aWxlL3RpbGVneC5jIHwgNiArKystLS0KPiAgIDEgZmlsZSBjaGFuZ2Vk
LCAzIGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25zKC0pCgpBY2tlZC1ieTogQ2hyaXMgTWV0Y2Fs
ZiA8Y21ldGNhbGZAbWVsbGFub3guY29tPgoKLS0gCkNocmlzIE1ldGNhbGYsIE1lbGxhbm94IFRl
Y2hub2xvZ2llcwpodHRwOi8vd3d3Lm1lbGxhbm94LmNvbQoKX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KWTIwMzggbWFpbGluZyBsaXN0ClkyMDM4QGxpc3Rz
LmxpbmFyby5vcmcKaHR0cHM6Ly9saXN0cy5saW5hcm8ub3JnL21haWxtYW4vbGlzdGluZm8veTIw
MzgK
