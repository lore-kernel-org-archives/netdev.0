From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] ehea: add kexec support
Date: Mon, 29 Oct 2007 09:32:17 +1100
Message-ID: <1193610737.9637.1.camel@concordia>
References: <200710261437.29117.ossthema@de.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ATWZuS5Lm8sq4ZfYPXwY"
Cc: Jeff Garzik <jeff@garzik.org>, Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47053 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752359AbXJ1WcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 18:32:19 -0400
In-Reply-To: <200710261437.29117.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ATWZuS5Lm8sq4ZfYPXwY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Fri, 2007-10-26 at 14:37 +0200, Jan-Bernd Themann wrote:
> eHEA resources that are allocated via H_CALLs have a unique identifier ea=
ch.
> These identifiers are necessary to free the resources. A reboot notifier
> is used to free all eHEA resources before the indentifiers get lost, i.e
> before kexec starts a new kernel.
>=20
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
>=20

How do you plan to support kdump?

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-ATWZuS5Lm8sq4ZfYPXwY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHJQ3xdSjSd0sB4dIRAhOeAKCEzaMVIPKt463BuNy0opmESDSpJQCgv7Li
NHEDkMAat1QUPzdxUk9Zu7A=
=PlOw
-----END PGP SIGNATURE-----

--=-ATWZuS5Lm8sq4ZfYPXwY--

