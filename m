From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 00/22] Add HiSilicon RoCE driver
Date: Fri, 24 Jun 2016 18:55:19 +0300
Message-ID: <20160624155519.GJ23995@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JsihDCElWRmQcbOr"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1466087730-54856-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--JsihDCElWRmQcbOr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 10:35:08PM +0800, Lijun Ou wrote:
> The HiSilicon Network Substem is a long term evolution IP which is
> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
> Sybsystem) also has a hardware support of performing RDMA with
> RoCEE.
> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
> will support mulitple versions of SOCs in future. This version of driver
> is meant to support Hip06 SoC(which confirms to RoCEv1 hardware
> specifications).
>=20
> Changes v9 -> v10:

I stopped my review on patch 9.

--JsihDCElWRmQcbOr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXbVfnAAoJEORje4g2clinSegP/3Kfa69WET/qqaTWcrAV7NLZ
lomCxmAMRSmf6PFxPzESXNT9XMFGr7wa0T4cYeWfz78Fw9dNOJaSreLqAFJCw7vM
Zh3HnauTZs1tSa6Uo/tkDRk1VLOdGsQAGgbPkKM0ye4UBTq40tZknZoTDpy5CmCh
cGW28Q2wozB71SM6WSxd2IFru7PEeUp5+3IDxZ7ph2PJmXJ/b5eyE1Hp+ga2EbdK
7w2W+3NXIYbIWLxM1ndowv0H/PHKnRBi6TFXMqc4Swv5Q8rj2IUvLueOWCARl5PY
XyemcPpD7jCVBYdY11lcTIiAdCGQslcjCjnuLm96FQ2nMy0LmsTXSc2g7uSO96R3
x8ASOlAAhCqWdfS/VAI7vt1QK7gJgNeIILEYE2HfFYmC1WaaR2vXll4ZIWMdbOm0
6PDamnlaL8W0P9ImBVONZZHdrkJcLNTROMqkC9Dx1hsdfT9KBXJgobYXS1aC3/GL
rFRMFrGwf94xzNhFAoW21aXz/Gs7sFT3hLu7YKIdvhbWw8jRpMXVOb60us6m1X9L
IzI0Re0JPffSYSD92lotqjS7h1GUqdTxtnDsTeozFFBnHodMCDCIuRwBr8FUudU4
VVibYSzd8lesR6Oaa7d9MltlBgCz+rIXfoqgpPfJAvn2gK/b38g1hTOTdvVXq7Vb
CunBQsGLas18/VfIyuA3
=i1mc
-----END PGP SIGNATURE-----

--JsihDCElWRmQcbOr--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
