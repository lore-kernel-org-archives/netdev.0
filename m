From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [e1000_netpoll] BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Wed, 27 Jul 2016 14:38:07 -0700
Message-ID: <1469655487.2232.49.camel@intel.com>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com>
	 <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0v4/w1PhRqR9lEWB2Ui3"
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Satyam Sharma <satyam@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	intel-wired-lan@lists.osuosl.org,
	Ye Xiaolong <xiaolong.ye@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0v4/w1PhRqR9lEWB2Ui3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64

T24gVHVlLCAyMDE2LTA3LTI2IGF0IDExOjE0ICswMjAwLCBFcmljIER1bWF6ZXQgd3JvdGU6Cj4g
Q291bGQgeW91IHRyeSB0aGlzID8KPiAKPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJu
ZXQvaW50ZWwvZTEwMDAvZTEwMDBfbWFpbi5jCj4gYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRl
bC9lMTAwMC9lMTAwMF9tYWluLmMKPiBpbmRleAo+IGY0MjEyOWQwOWUyYzIzYmE5ZmRiNWNkZTg5
MGQ1MGVjYjcxNjZhNDIuLmE1M2M0MWM0YzRmN2QxZmU1MmY5NWEyY2FiODc4NGEKPiA5MzhiMzgy
MGIgMTAwNjQ0Cj4gLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDAvZTEwMDBf
bWFpbi5jCj4gKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDAvZTEwMDBfbWFp
bi5jCj4gQEAgLTUyNTcsOSArNTI1NywxMyBAQCBzdGF0aWMgdm9pZCBlMTAwMF9uZXRwb2xsKHN0
cnVjdCBuZXRfZGV2aWNlCj4gKm5ldGRldikKPiDCoHsKPiDCoMKgwqDCoMKgwqDCoMKgc3RydWN0
IGUxMDAwX2FkYXB0ZXIgKmFkYXB0ZXIgPSBuZXRkZXZfcHJpdihuZXRkZXYpOwo+IMKgCj4gLcKg
wqDCoMKgwqDCoMKgZGlzYWJsZV9pcnEoYWRhcHRlci0+cGRldi0+aXJxKTsKPiAtwqDCoMKgwqDC
oMKgwqBlMTAwMF9pbnRyKGFkYXB0ZXItPnBkZXYtPmlycSwgbmV0ZGV2KTsKPiAtwqDCoMKgwqDC
oMKgwqBlbmFibGVfaXJxKGFkYXB0ZXItPnBkZXYtPmlycSk7Cj4gK8KgwqDCoMKgwqDCoMKgaWYg
KG5hcGlfc2NoZWR1bGVfcHJlcCgmYWRhcHRlci0+bmFwaSkpIHsKPiArwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgYWRhcHRlci0+dG90YWxfdHhfYnl0ZXMgPSAwOwo+ICvCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqBhZGFwdGVyLT50b3RhbF90eF9wYWNrZXRzID0gMDsKPiArwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgYWRhcHRlci0+dG90YWxfcnhfYnl0ZXMgPSAwOwo+
ICvCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBhZGFwdGVyLT50b3RhbF9yeF9wYWNrZXRz
ID0gMDsKPiArwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgX19uYXBpX3NjaGVkdWxlKCZh
ZGFwdGVyLT5uYXBpKTsKPiArwqDCoMKgwqDCoMKgwqB9Cj4gwqB9Cj4gwqAjZW5kaWYKPiDCoAoK
U2luY2UgdGhpcyBmaXhlcyB0aGUgaXNzdWXCoEZlbmdndWFuZyBzYXcsIHdpbGwgeW91IGJlIHN1
Ym1pdHRpbmcgYSBmb3JtYWwKcGF0Y2ggRXJpYz8gKHBsZWFzZSkgSSBjYW4gZ2V0IHRoaXMgcXVl
dWVkIHVwIGZvciBEYXZlJ3MgbmV0IHRyZWUgYXMgc29vbgphcyBJIHJlY2VpdmUgdGhlIGZvcm1h
bCBwYXRjaC4=


--=-0v4/w1PhRqR9lEWB2Ui3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXmSnAAAoJEOVv75VaS+3OpkQP/15jUfxKcOg2Ljwvo3zn7tLY
KqS0n6rk+t2sVnwpZEwF44czkUPIZDbd7534ftSlLe7bfDhQQv/ioz8fA5I1UuHs
QRlkKnlOtyRJalkR+LubEjX7QCyuZd1HfxzXkGLP3gbX1hX0wXHzDNuNMiLV1D9t
LPq83g5mIsPWis00hhN+XPghWJKW1RaWl5qfOHCyGGuQtVT15bbulGzLNwqeTSdH
38O64zmRbkLpEdf1JoR60eypEBWv3acZNkv1I2Epna0YAKyVPyVMnNJRb/1UBEqW
DZ69HvNwVjnA/L27EjWP5Sqac0s5qe1h0hq+dFh4h99e0skc4e5VqRtRyFu7bNKM
hLF50IYvf8MUZ886KHN3YB2XgJbzXbg1mR69TPFej7/rpwUuW5vP66GAj54Eci8m
XgI1lXwDn7wEy+aED0oDZ3LEEKpl6L3xdT5anY7LwbTpXJrjJN9J+zeqyiuFlqyn
XLkNdOREY2Ff7+bCEcaPob7aebazHgtnFpwwyDNURgLNLbo5DoYKonQTXHBZVfOu
Xw0KPfMLivFyrOI8+b8xiU6OD+fGEHtK4c7QOXhhAKCnhSg1fRrRS2mu9P/kgCoe
bSdOY7H7Iyz+W1B7+dLNCfhHW5IRhHWyIaf93BEHwTcZ4x9MtCbc3JLeiMmb4E+/
30lAvRN4ZQDmd+zdkXAE
=eqm2
-----END PGP SIGNATURE-----

--=-0v4/w1PhRqR9lEWB2Ui3--
