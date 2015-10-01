From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 03/12] net: igb: avoid using timespec
Date: Thu, 1 Oct 2015 21:17:45 +0200
Message-ID: <20151001191745.GC1872@localhost.localdomain>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <1443612402-3000775-4-git-send-email-arnd@arndb.de>
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
In-Reply-To: <1443612402-3000775-4-git-send-email-arnd@arndb.de>
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

QXJuZAoKQXMgYXV0aG9yIG9mIHRoZXNlIHNuaXBwZXRzLCBJIHdlbnQgYWhlYWQgYW5kIHJldmll
d2VkLiAgSSBoYXZlIG9uZQpjb21tZW50LCBiZWxvdy4KClJldmlld2VkLWJ5OiBSaWNoYXJkIENv
Y2hyYW4gPHJpY2hhcmRjb2NocmFuQGdtYWlsLmNvbT4KCk9uIFdlZCwgU2VwIDMwLCAyMDE1IGF0
IDAxOjI2OjMzUE0gKzAyMDAsIEFybmQgQmVyZ21hbm4gd3JvdGU6Cj4gZGlmZiAtLWdpdCBhL2Ry
aXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9pZ2JfcHRwLmMgYi9kcml2ZXJzL25ldC9ldGhl
cm5ldC9pbnRlbC9pZ2IvaWdiX3B0cC5jCj4gaW5kZXggNTk4MmYyOGQ1MjFhLi5jNDRkZjg3YzM4
ZGUgMTAwNjQ0Cj4gLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaWdiL2lnYl9wdHAu
Ywo+ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9pZ2JfcHRwLmMKPiBAQCAt
MTQzLDcgKzE0Myw3IEBAIHN0YXRpYyB2b2lkIGlnYl9wdHBfd3JpdGVfaTIxMChzdHJ1Y3QgaWdi
X2FkYXB0ZXIgKmFkYXB0ZXIsCj4gIAkgKiBzdWItbmFub3NlY29uZCByZXNvbHV0aW9uLgo+ICAJ
ICovCj4gIAl3cjMyKEUxMDAwX1NZU1RJTUwsIHRzLT50dl9uc2VjKTsKPiAtCXdyMzIoRTEwMDBf
U1lTVElNSCwgdHMtPnR2X3NlYyk7Cj4gKwl3cjMyKEUxMDAwX1NZU1RJTUgsICh1MzIpdHMtPnR2
X3NlYyk7CgpUaGlzIGNhc3QgaXMgdW5uZWNlc3NhcnksIGJlY2F1c2Ugd3IzMiBpcyB3cml0ZWws
IGFuZCB0aGF0IHBhcmFtZXRlcgppcyBhIHUzMi4KClRoYW5rcywKUmljaGFyZAoKPiAgfQo+ICAK
PiAgLyoqCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClky
MDM4IG1haWxpbmcgbGlzdApZMjAzOEBsaXN0cy5saW5hcm8ub3JnCmh0dHBzOi8vbGlzdHMubGlu
YXJvLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3kyMDM4Cg==
