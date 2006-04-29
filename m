From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] rt2x00: Compile fix and kernel version cleanup
Date: Sat, 29 Apr 2006 11:26:39 +0200
Message-ID: <200604291126.56978.IvDoorn@gmail.com>
References: <200604282052.44767.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1251548.PP4yHxGDBX";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.189]:41718 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750864AbWD2JZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2006 05:25:50 -0400
Received: by nproxy.gmail.com with SMTP id x30so1605782nfb
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2006 02:25:49 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200604282052.44767.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1251548.PP4yHxGDBX
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 20:52, Ivo van Doorn wrote:
> From: Ivo van Doorn <IvDoorn@gmail.com>
>=20
> During CVS merge I noticed several compilation errors have sneaked
> into the git version of rt2x00.
> - PRIO_ENTRIES define has been removed, TX_ENTRIES should be used
> - poll_delay module argument is of the type short
> - Remove LINUX_VERSION_CODE checks.
> - Fix missing byteordering type
> - Fix typo in usb_device
>=20
> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

Please drop this patch, I'll resend a correct verion in a few minutes.
The LINUX_VERSION_CODE checks removal was obviously wrong.

--nextPart1251548.PP4yHxGDBX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUzFgaqndE37Em0gRAjNbAJ9JTUM7t3/n966kaQtnZoUJIUOgRACfaBfk
a1NLdneCzUBAwssZQf4lTu0=
=NbmP
-----END PGP SIGNATURE-----

--nextPart1251548.PP4yHxGDBX--
