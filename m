From: Harald Welte <laforge@gnumonks.org>
Subject: Re: kernel crash with G5 Xserve and sungem driver
Date: Fri, 1 Oct 2004 21:46:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001194630.GO27499@sunbeam.de.gnumonks.org>
References: <415D8768.8080808@nortelnetworks.com> <20041001193153.GN27499@sunbeam.de.gnumonks.org> <415DB334.4010809@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Bzq2cJcN05fcPrs+"
Cc: netdev@oss.sgi.com, linuxppc-dev@ozlabs.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Content-Disposition: inline
In-Reply-To: <415DB334.4010809@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Bzq2cJcN05fcPrs+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 01, 2004 at 01:42:44PM -0600, Chris Friesen wrote:
> Harald Welte wrote:
>=20
> >Just don't compile (or load) the sungem driver on those boxes.
>=20
> Hmm.  That's a pain.  We've got G5 desktops too, and it would be nice to =
be=20
> able to run one kernel for both.  It'd be better (IMHO) to fix the driver=
=20
> so it doesn't crash.

I recommend talking to Bejamin Herrenschmidt, IIRC he already had
something in mind in order to fix the issue.

I mean, you can always hardcode some exemption into the driver, that's
two easy lines ;)

> Chris

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--Bzq2cJcN05fcPrs+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBXbQWXaXGVTD0i/8RAolKAJ92G/5zs4wo4XSF2WAsqAaD1+GIkwCeICAs
cHBju+40g4MUwbRTfk6R/Zs=
=qWQ2
-----END PGP SIGNATURE-----

--Bzq2cJcN05fcPrs+--
