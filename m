From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [STABLE REQUEST] add: e1000: fix lockdep splat in shutdown
 handler
Date: Sun, 14 Oct 2012 10:47:57 +0100
Message-ID: <1350208077.4832.76.camel@deadeye.wl.decadent.org.uk>
References: <1349993385.24256.79.camel@gandalf.local.home>
	 <20121011.182214.2229957213838024407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-sXYyfrqyjadw1YBOTpQo"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de, stable@vger.kernel.org,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121011.182214.2229957213838024407.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sXYyfrqyjadw1YBOTpQo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-10-11 at 18:22 -0400, David Miller wrote:
> From: Steven Rostedt <rostedt@goodmis.org>
> Date: Thu, 11 Oct 2012 18:09:45 -0400
>=20
> > Can you add this to the 3.2 stable tree.
> >=20
> > commit 3a3847e007aae732d64d8fd1374126393e9879a3
> > Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Date:   Wed Jan 4 20:23:33 2012 +0000
> >=20
> >     e1000: fix lockdep splat in shutdown handler
>=20
> Acked-by: David S. Miller <davem@davemloft.net>

Added to the queue, thanks.

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.

--=-sXYyfrqyjadw1YBOTpQo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUHqKTee/yOyVhhEJAQrn2xAAkEVVKn+5lXPi0rAPmWjPf1zkeud5k8vt
3ymeI79sHk9/LJblCXslH1uNefPIJHkQBe+znKku0Zjt2lVqcBmv3JWZGFHOpDSN
yZf6biyU1SwB4Z0aBwuTsvNche262K2uBfK54pVW+fics9bjSv7xuDC4HyEJZowp
QV2Tt8Czr1EulOC8nUTLGbuU0fab9sJCca43VnJQUgGZK3euNF0CNXREqovhYwRY
3BFbqO42ZwWkapsFG1O8HBP9Yk6sYZ+eblkB9Ca2RdkX0ragjJbI7gxQgVEjpepu
UcOEjdHEGme5ed/TrDDT/53vIfV6l7fFoqFXDVgFz8qqi3kG2U0Ny0oxOHV3pk2j
lnLS/x40IVd2cS/o6eYunOlVQaEM2lZQf9oXiqzFogztfe87hmWv8sLhKKWLAjSA
7ykiMCR0lzcHjtoglBi+YnbrODqrEdZd2Ta771JkikzaBTGsoDkqz+6g1atJOKNk
mFo2Ln4YEnTJE1G16Gz0ChBEhNQKATiwva1rtn1w5CovIWskov+RBox5tYhlPOcu
EHrTek92GtcK4a9mVam3uyVZvF1PujK94f4r3yXduX5f3HsBn8tj48D9eqYNdvOk
TD2F0tkX41S+eCDwMwtBUeNRKRhaYjd2j03sdv0eBbBoM8nD8uYKuHc78bsfkQeb
KcoIv631PdU=
=F9g8
-----END PGP SIGNATURE-----

--=-sXYyfrqyjadw1YBOTpQo--
