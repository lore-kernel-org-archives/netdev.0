From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Sat, 13 Aug 2005 16:51:57 +0200
Message-ID: <20050813145157.GB4551@rama.de.gnumonks.org>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<42FC0F01.5090802@trash.net>
	<20050812115622.GD16325@rama.de.gnumonks.org>
	<42FD4AC6.2020506@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="K8nIJk4ghYZn606h"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42FD4AC6.2020506@trash.net>
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


--K8nIJk4ghYZn606h
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 13, 2005 at 03:20:06AM +0200, Patrick McHardy wrote:
> Harald Welte wrote:
> >Just send two incremental patches to Dave.
>=20
> Here they are. The first patch fixes the div64_64 function, the second
> one renames some constants.

Ok,  just in case Dave was waiting for my comments (which are usually
not required since Patricks patches tend to have a higher quality than
mine):

ACK-ed-by: Harald Welte <laforge@netfilter.org>
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--K8nIJk4ghYZn606h
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC/gkMXaXGVTD0i/8RAkCpAJ0TMh9TdGfyVHMcXzhupXVttcLPYwCgoJ1D
xaKSDyrA+tIiSbll4DspiD4=
=Yr6A
-----END PGP SIGNATURE-----

--K8nIJk4ghYZn606h--
