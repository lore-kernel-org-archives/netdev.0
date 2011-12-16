From: Ben Hutchings <ben@decadent.org.uk>
Subject: RE: [linux-firmware v6 2/4] rtl_nic: add new firmware for RTL8111F
Date: Fri, 16 Dec 2011 05:18:10 +0000
Message-ID: <1324012690.2825.271.camel@deadeye>
References: <1319634425-1529-1-git-send-email-hayeswang@realtek.com>
	 <1319634425-1529-2-git-send-email-hayeswang@realtek.com>
	 <81662BFCE8FC4C70A9260DE3A1A52B78@realtek.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-e1Xfqi1bMaH9T1GuGN7k"
Cc: dwmw2@infradead.org, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56598 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750900Ab1LPFS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 00:18:27 -0500
In-Reply-To: <81662BFCE8FC4C70A9260DE3A1A52B78@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-e1Xfqi1bMaH9T1GuGN7k
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-11-17 at 20:16 +0800, hayeswang wrote:
>=20
> > -----Original Message-----
> > From: Hayeswang [mailto:hayeswang@realtek.com]=20
> > Sent: Wednesday, October 26, 2011 9:07 PM
> > To: dwmw2@infradead.org; ben@decadent.org.uk
> > Cc: romieu@fr.zoreil.com; netdev@vger.kernel.org; Hayeswang
> > Subject: [linux-firmware v6 2/4] rtl_nic: add new firmware=20
> > for RTL8111F
> >=20
> > Add new firmware:
> > 1. rtl_nic/rtl8168f-1.fw
> >    version: 0.0.3
> > 2. rtl_nic/rtl8168f-2.fw
> >    version: 0.0.3
> >=20
> > Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> > ---
> >  WHENCE                |    6 ++++++
> >  rtl_nic/rtl8168f-1.fw |  Bin 0 -> 3136 bytes
> >  rtl_nic/rtl8168f-2.fw |  Bin 0 -> 992 bytes
> >  3 files changed, 6 insertions(+), 0 deletions(-)
> >  create mode 100644 rtl_nic/rtl8168f-1.fw
> >  create mode 100644 rtl_nic/rtl8168f-2.fw
> >=20
>=20
> Hi sirs,
>=20
> Excuse me. Someone asks me these firmwares. Are these pending? Any respon=
se?

Sorry Hayes, these were held up due to the rebuiling of kernel.org
services.

I already applied your earlier changes (v0.0.2 of the 8186E and 8186F
firmware) locally.  I have rebased this series of 4 patches on top of
that, and pushed the result out.  Please check that I got it right.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-e1Xfqi1bMaH9T1GuGN7k
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATurUkue/yOyVhhEJAQra3w/8DNxy9pxWISfvKdp3dpfBKRsURcEhZyo5
v+/1zQMk+QRbOCEMTwMahf8fPpvhUWe3CpB7AESakb66lmAPzvwT91dNLML2KySg
FTxPraK7XNmGkjEaC9K1gHPjvlIrgnYIL7F2C4+ZToITqo9q+/jVW0OJZwsjDV/U
uuc2adgSOSeU7Hl7E9n+BjL3o76Hm4ZREdVXEDDLMQxvwmKoI6OtkZLwgIgchdsW
Kg6u7GKAbJPaLjbZnyApImLwDJUl3Qm3Ad8hxQ4tyW17ubYb4CuGCgLPLBTik0JJ
rnhsfnDcVSCNAp/O1SZ6prCftHWuHWa7XDJWJxp1N2Z82zPwxwV3xnvVYfVlZWY+
zFWWmU3qNN8cGFhYJxOvfjhQcI+BrhJfGMjK7Er53idmGfKf5jbBi9xw6GgggMI4
tYBxgG0uMbLtnFyxtiDBO5Z+zutqO9ofU4ZZI/MxHQbNdDea0kFxIc2Mo+W/duvG
uljhHcLyOSNFiatNuKNK+tItPlWxXc9duuwjNw2d7eGz6S8R+a3W9VSXydRH5DsM
0h+whDC0ifwz3FVHdxOrl3ma6ruMFgGInzCTdwNBvixE9ToGUVxjkF2unQl/kYPZ
3Dw5RTgQg43k8wlXYWr6/XebJokLmSXlMbk5xEhMKMLumRJ3JnKZiB1izaoH4F4q
INZFilnWH7c=
=4iKW
-----END PGP SIGNATURE-----

--=-e1Xfqi1bMaH9T1GuGN7k--
