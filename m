From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Fwd: [PATCH] net:usb:cdc_ncm: fix that tag Huawei devices as wwan
Date: Sun, 14 Jun 2015 13:51:46 -1000
Message-ID: <CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww@mail.gmail.com>
References: <SNT147-W99A0E937260823EBAA1FFB3B90@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b3a9c122d67060518830661
Cc: USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	=?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <SNT147-W99A0E937260823EBAA1FFB3B90-MsuGFMq8XAE@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--047d7b3a9c122d67060518830661
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hmm. Oliver is marked as the maintainer of the USB CDC code, but
others have touched it more recently. So I'm just wildly adding people
to the cc to comment on this patch and maybe apply it.
Oliver/David/Ben/Bj=C3=B8rn?

                Linus


---------- Forwarded message ----------
From: xiaomao <xiaomao0213-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date: Sun, Jun 14, 2015 at 1:18 PM
Subject: [PATCH] net:usb:cdc_ncm: fix that tag Huawei devices as wwan


Form: Qianni Mamaqianni-hv44wF8Li93QT0dZR+AlfA@public.gmane.org

Huawei devices is the gereric CDC_NCM devices, but not is WWAN
devices. In the patch, we deleted the code about tagging Huawei
devices as WWAN.
---

Signed-off-by:Qianni Mamaqianni-hv44wF8Li93QT0dZR+AlfA@public.gmane.org

--047d7b3a9c122d67060518830661
Content-Type: text/plain; charset=US-ASCII; name=patch
Content-Disposition: attachment; filename=patch
Content-Transfer-Encoding: base64
X-Attachment-Id: 539ff6d7bd437803_0.1

LS0tIGxpbnV4LTMuMTkvZHJpdmVycy9uZXQvdXNiL2NkY19uY20uYy5vcmlnCTIwMTUtMDYtMTUg
MDE6Mjk6NTIuMzU0MjM4MDc5ICswODAwCisrKyBsaW51eC0zLjE5L2RyaXZlcnMvbmV0L3VzYi9j
ZGNfbmNtLmMJMjAxNS0wNi0xNSAwMTozMTowNC4wNzQyMzYyNDYgKzA4MDAKQEAgLTE1NzMsMTIg
KzE1NzMsMTIgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCB1c2JfZGV2aWNlX2lkIGNkY19kZQogCX0s
CiAKIAkvKiB0YWcgSHVhd2VpIGRldmljZXMgYXMgd3dhbiAqLwotCXsgVVNCX1ZFTkRPUl9BTkRf
SU5URVJGQUNFX0lORk8oMHgxMmQxLAorCS8qeyBVU0JfVkVORE9SX0FORF9JTlRFUkZBQ0VfSU5G
TygweDEyZDEsCiAJCQkJCVVTQl9DTEFTU19DT01NLAogCQkJCQlVU0JfQ0RDX1NVQkNMQVNTX05D
TSwKIAkJCQkJVVNCX0NEQ19QUk9UT19OT05FKSwKIAkgIC5kcml2ZXJfaW5mbyA9ICh1bnNpZ25l
ZCBsb25nKSZ3d2FuX2luZm8sCi0JfSwKKwl9LCovCiAKIAkvKiBJbmZpbmVvbihub3cgSW50ZWwp
IEhTUEEgTW9kZW0gcGxhdGZvcm0gKi8KIAl7IFVTQl9ERVZJQ0VfQU5EX0lOVEVSRkFDRV9JTkZP
KDB4MTUxOSwgMHgwNDQzLAo=
--047d7b3a9c122d67060518830661--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
