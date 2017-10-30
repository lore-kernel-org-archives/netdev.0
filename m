From: Mark Brown <broonie@kernel.org>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 30 Oct 2017 18:10:30 +0000
Message-ID: <20171030181030.e2te534v3ntiaht6@sirena.co.uk>
References: <20171030170224.badokg3dsgjb4hvg@sirena.co.uk>
 <20171030104307.0857ee38@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="ma366v4jrcsj2m65"
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171030104307.0857ee38@cakuba.netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ma366v4jrcsj2m65
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 30, 2017 at 10:43:07AM -0700, Jakub Kicinski wrote:
> On Mon, 30 Oct 2017 17:02:24 +0000, Mark Brown wrote:

> > is submitted for merging.  You may also want to consider cooperating
> > with the maintainer of the conflicting tree to minimise any particularly
> > complex conflicts.

> Unfortunately, this is not a correct resolution.  Please see below.

So I actually ended up just throwing this away (and the rest of what was
going on for net-next, there were just far too many of these self
conflicts.  The tree is one of the bigger time sinks when doing -next
but today was particularly heavy.

--ma366v4jrcsj2m65
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAln3axUACgkQJNaLcl1U
h9CXjgf/TaLbFO7umuZYjNya/7YD+FmYH1eVONppb5pQwpZJANWAotLxTQDEI0xc
g9gSDuCMmMJFtZ/Vi1wu2v/oT8UHdfZ5/Dq8v1qSZ1ppFRHOSVcEEs6BD0vVJxVv
9MQV25OiivHbPNdr3+dWPWjXgsSDbed8nCGF25pOuoE5B7l2mzfWyieObhp68ARm
tJ+Shl7K9w6+890hgd6wZVa6j7CHXeZRmEtLvXinjcTfUbmOk8CO3vlc3Mk2nY7K
0j3PRFhSUPa+1CyPr2ZT8jZfgJ5pjmNkChODxzQlbS26woZnM7ECMghNtxhtCgin
rbinBS6fUyhCncpghj6lAAGpr9PwHw==
=C0Hp
-----END PGP SIGNATURE-----

--ma366v4jrcsj2m65--
