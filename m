From: martin f krafft <madduck@madduck.net>
Subject: Re: non-root, non-real network manipulation for netconf testing
Date: Tue, 3 Jun 2008 12:20:50 +0200
Message-ID: <20080603102050.GA14461@lapse.madduck.net>
References: <20080603080529.GA9010@lapse.madduck.net>
	<20080603100513.GA18161@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6186304913721716731=="
Cc: netdev discussion list <netdev@vger.kernel.org>,
	netconf developers list <netconf-devel@lists.alioth.debian.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netconf-devel-bounces+glddn-netconf-devel=m.gmane.org@lists.alioth.debian.org>
In-Reply-To: <20080603100513.GA18161@solarflare.com>
List-Unsubscribe: <http://lists.alioth.debian.org/mailman/listinfo/netconf-devel>,
	<mailto:netconf-devel-request@lists.alioth.debian.org?subject=unsubscribe>
List-Archive: <http://lists.alioth.debian.org/pipermail/netconf-devel>
List-Post: <mailto:netconf-devel@lists.alioth.debian.org>
List-Help: <mailto:netconf-devel-request@lists.alioth.debian.org?subject=help>
List-Subscribe: <http://lists.alioth.debian.org/mailman/listinfo/netconf-devel>,
	<mailto:netconf-devel-request@lists.alioth.debian.org?subject=subscribe>
Mime-version: 1.0
Sender: netconf-devel-bounces+glddn-netconf-devel=m.gmane.org@lists.alioth.debian.org
Errors-To: netconf-devel-bounces+glddn-netconf-devel=m.gmane.org@lists.alioth.debian.org
List-Id: netdev.vger.kernel.org


--===============6186304913721716731==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CE+1k2dSO48ffgeK"
Content-Disposition: inline


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

also sprach Ben Hutchings <bhutchings@solarflare.com> [2008.06.03.1205 +020=
0]:
> Have you considering running the tests in User-Mode Linux or some
> other kind of virtualised environment?

Yes, but that would require root rights as well, and quite a lot of
setup, making it pretty unlikely that passerby developers would run
tests, or allowing me to run the tests automatically on build
daemons.

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
"work consists of whatever a body is obliged to do.
 play consists of whatever a body is not obliged to do."
                                                         -- mark twain
=20
spamtraps: madduck.bogus@madduck.net

--CE+1k2dSO48ffgeK
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIRRsCIgvIgzMMSnURAldJAKCV/Nu+lvv1VZTomJAetzszxvgeCwCdFcL9
HUcSGGez1Nb9FOU1H1PkZ0k=
=OfHe
-----END PGP SIGNATURE-----

--CE+1k2dSO48ffgeK--


--===============6186304913721716731==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============6186304913721716731==--
