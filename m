From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 15:09:28 +0100
Message-ID: <1340719768.5330.2.camel@deadeye.wl.decadent.org.uk>
References: <1340696951-2686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120626.005029.909254566674577767.davem@davemloft.net>
	 <1340697238.2255.20.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5vekbnniMHWAwz2l0gqk"
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52731 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739Ab2FZOJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 10:09:53 -0400
In-Reply-To: <1340697238.2255.20.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5vekbnniMHWAwz2l0gqk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-06-26 at 00:53 -0700, Jeff Kirsher wrote:
> On Tue, 2012-06-26 at 00:50 -0700, David Miller wrote:
> > Sorry, quotes don't work either, what you did is still a SMTP syntax er=
ror,
> > here's what is in the bounce I get back:
> >=20
> > 	<stable@vger.kernel.org> "[3.4]",
> > 	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Illegal-Object:	Syntax error in Cc: address found on vger.kernel.org:
> > 	Cc:	<stable@vger.kernel.org>"[3.4]"
> > 						^-missing end of address
>=20
> Grrr...
>=20
> I will re-send without the "[3.4]", Greg will just have to deal with it.

It's certainly not necessary to put anything like that in the real Cc
header. Many people put something like
'Cc: <stable@vger.kernel.org> # 3.4' in the body; I don't know if that
is more like likely to result in the version being stripped when
generating mail recipients.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-5vekbnniMHWAwz2l0gqk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT+nCmOe/yOyVhhEJAQqDYxAAzZrI6qNtGtLEkSYfuzV7JcB+LnQ6roFY
D6XaRADycBUYOcS3FGkBUDStxXf/meMAbQxVOTcLDxB+01D5VVNn1uVjDSvJUN8S
HMZBZcoVXHPaYC+k9d4kYXroL9Ku0AtD50x6vTPIW8sgZVbZNhRLFcl2CYCoFe+Q
MkDoaW0idou48oZrFz6tw+UqvJKlUS8Z/0uyoL70WuVrqMdpveRtLN/B4sVx6SFr
mgJeYjA3UG1Bh+A7yKmcyWxrbVfiGUR2XBlKZKd1+kI4APDSdXtWyF0O0yOA7V7k
rQCp1JqV/KxUgZ5u+HKTy99ZXm77/J4mfetJymcepl6WwOmcp/FSuEQcVWyl9EiX
DCVh0oe47ZXqgz+MYewUautBgegoPuQ+LYY3fMOqUJLUOCaAgbPa5OeG57x4RosJ
BohgZHSeYhu3MJKDQO/kzYFOadR6xdN4O6T6wnRFxIy7m8UIq2ZVnqPtFaJGe1Gi
VhRhmLd6qSIcgKnCfVlHTbaDpnTTOEqnUjWFxrTWtg2nSwRiZhtnzmU6tG9k1l2F
Sb0b24fmqE3qQ9hp5tPeB2Oh/FYXNMryxgtNGttS2JU7jTD0K4nw4Q7y6+aGjWXJ
TOxSQR70wsApExF7QGwWJbAg/Her/zm0Njj+ixSEgU+U5pwbCy2XaSsi/lDR8PF/
aDVBRpiZD0A=
=VdE4
-----END PGP SIGNATURE-----

--=-5vekbnniMHWAwz2l0gqk--
