From: Harald Welte <laforge@gnumonks.org>
Subject: Re: support of IPv6 by NFS
Date: Sun, 6 Mar 2005 12:02:25 +0100
Message-ID: <20050306110225.GV30487@sunbeam.de.gnumonks.org>
References: <42243F8D.5030302@bull.net> <200503010744.38339.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5G50dybFf3pRZKd7"
Cc: netdev@oss.sgi.com, usagi-users@linux-ipv6.org
To: Quantum Scientific <Info@Quantum-Sci.com>
Content-Disposition: inline
In-Reply-To: <200503010744.38339.Info@Quantum-Sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--5G50dybFf3pRZKd7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 01, 2005 at 07:44:37AM -0600, Quantum Scientific wrote:
> Also one must become an ip6tables expert in order to have a reasonably se=
cure=20
> firewall, because ip6tables and 6tables are dead, and Shorewall does not=
=20
> support IPV6 security for some reason.  Another deterrant.

I have to oppose that statement.  ip6tables is not dead, it's alive.
We're even at the brink of submitting nf_conntrack, the new connection
tracking engine that covers ipv4 and ipv6, to the mainline kernel.

I'm running a number of ipv6 packet filters, and as of now we are not
aware of any known issues or bugs in the current ip6tables code base.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--5G50dybFf3pRZKd7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCKuNBXaXGVTD0i/8RAjhEAKCZ4czid+6Xh03ONG47WLYgM8taCgCfWb14
SmFPlkNWE5FPhkbVRpgvGiw=
=feZj
-----END PGP SIGNATURE-----

--5G50dybFf3pRZKd7--
