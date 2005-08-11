From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2/2] fix NF_QUEUE_NR() macro
Date: Thu, 11 Aug 2005 21:26:57 +0200
Message-ID: <20050811192657.GJ5353@rama.de.gnumonks.org>
References: <20050811071320.GB4137@rama.de.gnumonks.org>
	<200508111631.24785.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Q59ABw34pTSIagmi"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Ingo Oeser <netdev@axxeo.de>
Content-Disposition: inline
In-Reply-To: <200508111631.24785.netdev@axxeo.de>
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


--Q59ABw34pTSIagmi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 11, 2005 at 04:31:24PM +0200, Ingo Oeser wrote:
> Harald Welte wrote:
> > Hi Dave, please apply!
>=20
> What about using a brace more:

I wouldn't mind the extra brace, but I don't want to make this more
difficult for Dave.  So it's his call whether he would manually edit the
line before applying the patch ;)

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--Q59ABw34pTSIagmi
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC+6aBXaXGVTD0i/8RAk6IAKCldCMTQd9ASocgm2L6vfTqe2rH+gCfSr24
0YzuGHPrIr/ByC5sH2TyU1U=
=mQ78
-----END PGP SIGNATURE-----

--Q59ABw34pTSIagmi--
