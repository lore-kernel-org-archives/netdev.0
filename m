From: Mike Kershaw <dragorn@kismetwireless.net>
Subject: Re: Remove Prism II support from Orinoco
Date: Wed, 14 Jun 2006 15:09:03 -0400
Message-ID: <20060614190903.GB8832@drd1812a>
References: <448F02F1.3070001@pcuf.fi>
Reply-To: Mike Kershaw <dragorn@kismetwireless.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uQr8t48UFsdbeI+V"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from melchior.nerv-un.net ([216.179.125.34]:64007 "EHLO nerv-un.net")
	by vger.kernel.org with ESMTP id S1750786AbWFNTJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 15:09:06 -0400
To: Jar <jar@pcuf.fi>
Content-Disposition: inline
In-Reply-To: <448F02F1.3070001@pcuf.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uQr8t48UFsdbeI+V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 13, 2006 at 09:24:49PM +0300, Jar wrote:
> It always loads itself with or without blacklist. That's why I have to=20
> do 'rm -f orinoco*.* && depmod -a' when the new kernel arrives. Seems=20
> that users are directed to use unsecure orinoco (wep) driver rather than=
=20
> secure hostap (wpa/wpa2,tkip,aes) driver for their prism2 hardware.

The hostap drivers are also much better behaved for rfmon than the
orinoco drivers for prism2.

-m

--=20
Mike Kershaw/Dragorn <dragorn@kismetwireless.net>
GPG Fingerprint: 3546 89DF 3C9D ED80 3381  A661 D7B2 8822 738B BDB1

Bus Error at 008BE426 while reading byte from DEADBEEF in User data space


--uQr8t48UFsdbeI+V
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFEkF7P17KIInOLvbERAl6kAJ9UzQEWcKoAuUjDjSCee9EHSuYvtQCfYoRc
Zft/bXMUI5G4Nnh3Kj+Bttc=
=4Drj
-----END PGP SIGNATURE-----

--uQr8t48UFsdbeI+V--
