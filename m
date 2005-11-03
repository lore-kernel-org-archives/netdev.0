From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 1/2] [NETFILTER] PPTP helper: Fix compilation of
	conntrack helper without NAT
Date: Thu, 3 Nov 2005 14:19:17 +0100
Message-ID: <20051103131917.GJ4479@sunbeam.de.gnumonks.org>
References: <20051103120404.GB4479@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ti5ZTCIkqg9s5lPK"
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
In-Reply-To: <20051103120404.GB4479@sunbeam.de.gnumonks.org>
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


--ti5ZTCIkqg9s5lPK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 03, 2005 at 01:04:04PM +0100, Harald Welte wrote:
> Hi Acme!
>=20
> Please merge this to both 2.6.15 mainline and 2.6.14.x stable series,
> thanks.

*sigh*. this is not my day.  Please do _not_ apply this patch number 1.
I'll re-send a replacement.

Patch number '2' is fine and should go in.

Sorry for the mess.
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--ti5ZTCIkqg9s5lPK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDag5VXaXGVTD0i/8RAlLaAJ9/llDyZkPrJgO8vJurKvF6RRm92wCeONZc
6l3p8wOxbouu8fn+ZXOYzpc=
=uqcC
-----END PGP SIGNATURE-----

--ti5ZTCIkqg9s5lPK--
