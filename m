From: Harald Welte <laforge@gnumonks.org>
Subject: Re: Intel and TOE in the news
Date: Sun, 6 Mar 2005 12:21:04 +0100
Message-ID: <20050306112104.GX30487@sunbeam.de.gnumonks.org>
References: <20050221132844.GU31837@postel.suug.ch> <1108994621.1089.158.camel@jzny.localdomain> <20050221141714.GV31837@postel.suug.ch> <1108996313.1090.178.camel@jzny.localdomain> <20050221153443.GW31837@postel.suug.ch> <1109000925.1076.3.camel@jzny.localdomain> <20050221164006.GY31837@postel.suug.ch> <1109005385.1074.68.camel@jzny.localdomain> <1109016740.25476.2.camel@mcmanus.datapower.com> <1109020362.1077.134.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Tcb1KvpfnM4LxW2s"
Cc: patrick mcmanus <mcmanus@ducksong.com>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1109020362.1077.134.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Tcb1KvpfnM4LxW2s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Sorry for my late catch-up, didn't have time to read all mailinglists
for some time.

On Mon, Feb 21, 2005 at 04:12:42PM -0500, jamal wrote:
> CSA is essentially a direct link to the Northbridge System Controller
> (or MCH); there are some speacilized motherboards that have this
> feature.=20

It's actually becoming more and more common.  But there are only MCH's
with a single CSA port, so you will never benefit from it if you need
more than one port.

Like everything intel seems to do (i've read about everything I could
find about their recent press releases), they concentrate on the end
host case, not packet forwarding :(

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--Tcb1KvpfnM4LxW2s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCKuegXaXGVTD0i/8RAudCAJ936W3c7kJ93mPm0BKKff4V4fVadgCeLMXF
d+dSLUpr2RP2bI+X+ibTVh8=
=nTDy
-----END PGP SIGNATURE-----

--Tcb1KvpfnM4LxW2s--
