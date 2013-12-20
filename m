From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 01/11] staging: r8188eu: Remove pointless thread_exit macro
Date: Fri, 20 Dec 2013 11:18:16 -0800
Message-ID: <20131220191816.GB27254@kroah.com>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
 <1387514323-4486-2-git-send-email-Larry.Finger@lwfinger.net>
 <20131220165859.GA12829@kroah.com> <52B47CDB.506@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <52B47CDB.506@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

T24gRnJpLCBEZWMgMjAsIDIwMTMgYXQgMTE6MjI6MzVBTSAtMDYwMCwgTGFycnkgRmluZ2VyIHdy
b3RlOgo+IE9uIDEyLzIwLzIwMTMgMTA6NTggQU0sIEdyZWcgS0ggd3JvdGU6Cj4gPiBXaXRoIHRo
aXMgc2VyaWVzIGFwcGxpZWQsIEkgZ2V0IGEgdG9uIG9mICJ1bnVzZWQgdmFyaWFibGUiIHdhcm5p
bmdzLCBjYW4KPiA+IHlvdSBwbGVhc2UgZml4IHRoZW0gdXAgbm93IHRvbz8KPiAKPiBTdHJhbmdl
LCBidXQgSSBkb24ndCBnZXQgYW55LiBNeSBjb21waWxlciBpcyBnY2MgKFNVU0UgTGludXgpIDQu
OC4xIDIwMTMwOTA5IAo+IFtnY2MtNF84LWJyYW5jaCByZXZpc2lvbiAyMDIzODhdIGZyb20gb3Bl
blNVU0UgMTMuMS4gV2hhdCB2ZXJzaW9uIGFyZSB5b3UgdXNpbmc/Cj4gCgpJJ20gdXNpbmcgYW4g
b2xkZXIgdmVyc2lvbjoKCSQgZ2NjIC0tdmVyc2lvbgoJZ2NjIChHZW50b28gNC43LjMtcjEgcDEu
MywgcGllLTAuNS41KSA0LjcuMwoKT2RkLiAgSSdsbCBtb3ZlIHVwIHRvIDQuOCBhbmQgdHJ5IHRo
YXQuLi4KCk5vcGUsIHNhbWUgcHJvYmxlbSwgaGVyZSdzIG9uZSBleGFtcGxlIGxpbmU6Cglkcml2
ZXJzL3N0YWdpbmcvcnRsODE4OGV1L2NvcmUvcnR3X2FwLmM6IEluIGZ1bmN0aW9uIOKAmHJ0d19h
cF9pbmZvcm1fY2hfc3dpdGNo4oCZOgoJZHJpdmVycy9zdGFnaW5nL3J0bDgxODhldS9jb3JlL3J0
d19hcC5jOjE3NzM6MTY6IHdhcm5pbmc6IHVudXNlZCB2YXJpYWJsZSDigJhpcnFM4oCZIFstV3Vu
dXNlZC12YXJpYWJsZV0KCSAgdW5zaWduZWQgbG9uZyBpcnFMOwoKVGhpcyBpcyB4ODYtNjQsIGNv
dWxkIHRoYXQgYmUgYW4gaXNzdWU/Cgp0aGFua3MsCgpncmVnIGstaApfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXZlbCBtYWlsaW5nIGxpc3QKZGV2ZWxA
bGludXhkcml2ZXJwcm9qZWN0Lm9yZwpodHRwOi8vZHJpdmVyZGV2LmxpbnV4ZHJpdmVycHJvamVj
dC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcml2ZXJkZXYtZGV2ZWwK
