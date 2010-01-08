From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Can we remove pci_find_device() yet?
Date: Fri, 8 Jan 2010 11:22:36 +1100
Message-ID: <20100108112236.462a3da2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__8_Jan_2010_11_22_36_+1100_n61xPJunSsPD3M0R"
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	Greg Kroah-Hartman <gregkh@suse.de>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:49333 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753256Ab0AHAWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 19:22:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__8_Jan_2010_11_22_36_+1100_n61xPJunSsPD3M0R
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

This interface has been deprecated since November 2006, so can something
be done about the last users (I think only some ISDN drivers)?  Or should
we just remove the interface and mark those drivers BROKEN (and maybe
move them to staging)?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__8_Jan_2010_11_22_36_+1100_n61xPJunSsPD3M0R
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktGeswACgkQjjKRsyhoI8zOnACgr/3bY0XN4/htVJZBClLknFS3
AvUAmwbRpv3TVqxGCAAT7204+h3xNlBW
=MLzZ
-----END PGP SIGNATURE-----

--Signature=_Fri__8_Jan_2010_11_22_36_+1100_n61xPJunSsPD3M0R--
