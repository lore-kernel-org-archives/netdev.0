From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 02/10]: [NETFILTER]: Defer fragmentation in ip_output
	when connection tracking is used
Date: Tue, 22 Nov 2005 15:19:37 +0100
Message-ID: <20051122141937.GT31478@sunbeam.de.gnumonks.org>
References: <43740DB5.9070206@trash.net>
	<20051115104425.GA31719@gondor.apana.org.au>
	<437BEAC8.40904@trash.net>
	<20051122075904.GL31478@sunbeam.de.gnumonks.org>
	<4382D419.6070705@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9Z5hYcGq4mWDMhAr"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4382D419.6070705@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--9Z5hYcGq4mWDMhAr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 22, 2005 at 09:17:29AM +0100, Patrick McHardy wrote:

> >>I've CCed Harald for his opinion in case I missed something.
> >I don't think you've missed something.  I agree that the features you
> >pointed out seem to be useful and/or important.
>=20
> I hope you meant to write "don't seem to be"? :)

yes.  I shouldn't be answering emails while holding a tutorial, sorry.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--9Z5hYcGq4mWDMhAr
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDgyj5XaXGVTD0i/8RArwXAKCFiWsWwFcI8Nm/EoYwPXqUJAB3rQCfdNVj
Rp5nUi7gXm4yGoAi9Z1MlZk=
=x9F0
-----END PGP SIGNATURE-----

--9Z5hYcGq4mWDMhAr--
