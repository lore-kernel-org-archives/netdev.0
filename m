From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Re: bnx2x - occasional high packet loss (on LAN)
Date: Mon, 21 Sep 2015 12:32:00 +0200
Message-ID: <20150921103200.GF6850@pcnci.linuxbox.cz>
References: <20150915041726.GD6850@pcnci.linuxbox.cz>
 <81D78EA7F834FA4C83B64260D494C8590870F221@avmb3.qlogic.org>
 <20150916081833.GE6850@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6v9BRtpmy+umdQlo"
Cc: netdev <netdev@vger.kernel.org>,
	"nik@linuxbox.cz" <nik@linuxbox.cz>
To: Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:58727 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756470AbbIUKcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 06:32:11 -0400
Content-Disposition: inline
In-Reply-To: <20150916081833.GE6850@pcnci.linuxbox.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6v9BRtpmy+umdQlo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Ariel,

after few days of torturing NICs with flood pings, card
seems to have given up with lots of errors..

I've uploaded new kernel log here:

http://nik.lbox.cz/download/dmesg.txt

Will this help?

I still have it in this hung state now, in case I could provide
more info for diagnostics..

however please note this can be different problem then I was reporting
originaly, since I only had high packet loss, while now whole card
seems to be blocked..  but maybe it just is worse case of the same
problem?

BR

nik





On Wed, Sep 16, 2015 at 10:18:34AM +0200, Nikola Ciprich wrote:
> On Wed, Sep 16, 2015 at 08:15:41AM +0000, Ariel Elior wrote:
> > Hi Nikola,
> > Please provide dmesg output from your system.
> > Thanks,
> > Ariel
>=20
> Hello Ariel,
>=20
> here it is:
>=20
> http://nik.lbox.cz/download/dmesg.txt
>=20
> BR
>=20
> nik
>=20
>=20
> >=20
>=20
>=20
> --=20
> -------------------------------------
> Ing. Nikola CIPRICH
> LinuxBox.cz, s.r.o.
> 28.rijna 168, 709 00 Ostrava
>=20
> tel.:   +420 591 166 214
> fax:    +420 596 621 273
> mobil:  +420 777 093 799
> www.linuxbox.cz
>=20
> mobil servis: +420 737 238 656
> email servis: servis@linuxbox.cz
> -------------------------------------



--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28.rijna 168, 709 00 Ostrava

tel.:   +420 591 166 214
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--6v9BRtpmy+umdQlo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlX/3KAACgkQ3xdJJrLygV5LQACeOa9pIb1Hv5OoMhiQijzHNlMU
2HEAn0R0bmzGOteoO+3SIDcHWeNYH2Se
=htLW
-----END PGP SIGNATURE-----

--6v9BRtpmy+umdQlo--
