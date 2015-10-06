From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH net-next v2 1/2] regmap: Allow installing custom
 reg_update_bits function
Date: Tue, 6 Oct 2015 16:07:07 +0100
Message-ID: <20151006150707.GT12635@sirena.org.uk>
References: <20151005142531.GS12635@sirena.org.uk>
 <20151005.232148.28609721470208031.davem@davemloft.net>
 <20151006095715.GF12635@sirena.org.uk>
 <20151006.062208.1154490262564827766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="eeQ5RemdMfmXqpfW"
Cc: jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151006.062208.1154490262564827766.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--eeQ5RemdMfmXqpfW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 06, 2015 at 06:22:08AM -0700, David Miller wrote:
> Date: Tue, 6 Oct 2015 10:57:15 +0100

> > I obviously can't just merge in net-next.

> People do this all the time, when needed.  My history never changes,
> and the networking tree is one of the first trees pulled into
> linux-next, so this is always safe.

Which would then make working with my tree annoying (I get net stuff
showing up in my diffs and logs) and gets in the way for sending pull
requests before Linus starts merging stuff which I tend to do.

--eeQ5RemdMfmXqpfW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWE+OXAAoJECTWi3JdVIfQV18H/jpco0v0uPN3+gETdCHpRNAM
nzhJaLBg85dNsD9+DP2FWqv3tYDs3uhJQy7ltxWUMEItpYe1/0dCWx12CbH3Qbev
GI5YP0vdMI1f7f/NgHqNZNBKcFocwhiuGqguq3lV5ZarC46ZFa7TIg631isPkOsp
uSGqZreyGhI3ysMX2ISifTjFFtCpwHPCMOTAjFjIUd44pibS4N4v0B76iS1VDFPm
naQfNlW9O3QIrqer8+eMf0IEdY/k48ZJDaCdGmXK0oeLLKDmTD9zwcOmR+6fa3Pn
S8+ypY5+ps/6lUAwL10Bks6Dfm+HqswiN82trmSpARfQmPQlVQ2oW7I5FPgXtto=
=6mJg
-----END PGP SIGNATURE-----

--eeQ5RemdMfmXqpfW--
