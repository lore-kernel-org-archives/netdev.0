From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.6] Re: xfrm_user.c doesn't use NLMSG_F_MULTI
Date: Wed, 20 Oct 2004 08:34:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020063440.GV21927@sunbeam.de.gnumonks.org>
References: <20041013080705.GB3387@obroa-skai.de.gnumonks.org> <E1CI2I2-0001sI-00@gondolin.me.apana.org.au> <20041014105757.GB12694@obroa-skai.de.gnumonks.org> <20041014110742.GA7910@gondor.apana.org.au> <20041015191444.GM17516@obroa-skai.de.gnumonks.org> <20041016094553.GA6546@gondor.apana.org.au> <20041019231256.1e4b039e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lA2zPjnDULdUXMNN"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041019231256.1e4b039e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--lA2zPjnDULdUXMNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 19, 2004 at 11:12:56PM -0700, David S. Miller wrote:

> I just installed Herbert's patches from that thread.
> Harald, you can redo your patch against that thread's
> patches or just wait until it hits Linus's tree tonight
> or tomorrow.

I'd rather wait, more convenient ;)

> Please also take care of the issue Herbert pointed out
> in the xfrm_user.c case wrt. dumping.

yes, I'll do so.  I didn't fix it right now (and repost) since Herbert
asked me to hold back.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--lA2zPjnDULdUXMNN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBdgcAXaXGVTD0i/8RAsYFAJ4mlhPDbYXm8JBB8+Zqzve6TS5UWwCdF44w
zDJEJ9WMcbFAbXT1m/daxaY=
=amLv
-----END PGP SIGNATURE-----

--lA2zPjnDULdUXMNN--
