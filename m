From: Sven Anders <anders@anduras.de>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sat, 25 Oct 2008 19:44:16 +0200
Message-ID: <49035AF0.6040700@anduras.de>
References: <1224892008.3919.27.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1D60D2909D2F47DFC38297F4"
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:57918 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbYJYRoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 13:44:21 -0400
In-Reply-To: <1224892008.3919.27.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1D60D2909D2F47DFC38297F4
Content-Type: multipart/mixed;
 boundary="------------060309050003020809020307"

This is a multi-part message in MIME format.
--------------060309050003020809020307
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Johannes Berg schrieb:
> This adds a new printf format specifier for the kernel, %pM,
> to be used to print out MAC addresses. This has advantages
> over the current print_mac scheme:
>  * no need for DECLARE_MAC_BUF
>  * can be used safely in statements that might be compiled
>    out without the print_mac call staying.

Nice, have you though of something similar for IPv4 and IPv6
adresses?

Regards
 Sven
--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS service solutions AG
 Innstra=DFe 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Rechtsform: Aktiengesellschaft - Sitz: Passau - Amtsgericht Passau HRB 60=
32
Mitglieder des Vorstands: Sven Anders, Marcus Junker
Vorsitzender des Aufsichtsrats: Mark Peters

--------------060309050003020809020307
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="anders.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
org:ANDURAS AG;Research and Development
adr;quoted-printable:;;Innstra=3DC3=3D9Fe 71;Passau;Bavaria;94036;Germany=

email;internet:anders@anduras.de
title:Dipl. Inf.
tel;work:++49 (0)851 / 490 50 -0
tel;fax:++49 (0)851 / 590 50 - 55
x-mozilla-html:FALSE
url:http://www.anduras.de
version:2.1
end:vcard


--------------060309050003020809020307--

--------------enig1D60D2909D2F47DFC38297F4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFJA1rz5lKZ7Feg4EcRAg1mAJwKAnnpIkSWRDdZ8iz9Gbpq7sXdMgCgjdon
x1mKwQZawhTnftL57JI/hTg=
=H1H2
-----END PGP SIGNATURE-----

--------------enig1D60D2909D2F47DFC38297F4--
