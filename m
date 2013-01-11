From: Roman Mamedov <rm@romanrm.ru>
Subject: Re: Problem with IPv6 Route Cache
Date: Fri, 11 Jan 2013 18:58:36 +0600
Message-ID: <20130111185836.43c13ce1@natsu>
References: <20130111185126.56cababe@natsu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/YloeVzNA=61V/ZBavPeJe55"; protocol="application/pgp-signature"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from len.romanrm.net ([176.31.121.172]:41053 "EHLO len.romanrm.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752409Ab3AKM6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 07:58:38 -0500
Received: from natsu (unknown [IPv6:fd39::1e6f:65ff:fea1:3ea6])
	by len.romanrm.net (Postfix) with ESMTPS id 8C8A8203CE
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 12:58:37 +0000 (UTC)
In-Reply-To: <20130111185126.56cababe@natsu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/YloeVzNA=61V/ZBavPeJe55
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 11 Jan 2013 18:51:26 +0600
Roman Mamedov <rm@romanrm.ru> wrote:

> The problem is, at some point presumably while the VPN interface is being=
 and
> at the same time the destination ULA subnet is being actively communicated
> with

Sorry, "while the VPN interface is being _restarted_ and".

--=20
With respect,
Roman

~~~~~~~~~~~~~~~~~~~~~~~~~~~
"Stallman had a printer,
with code he could not see.
So he began to tinker,
and set the software free."

--Sig_/YloeVzNA=61V/ZBavPeJe55
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlDwDHwACgkQTLKSvz+PZwitEACfXSim1z92Su/yzymkeZqS1xSE
5f4An1IXStYcDhW+0GynjgIjO9DC1GLX
=jKj1
-----END PGP SIGNATURE-----

--Sig_/YloeVzNA=61V/ZBavPeJe55--
