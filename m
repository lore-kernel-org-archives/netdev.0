From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [3.2.y] phy:icplus:fix Auto Power Saving in ip101a_config_init.
Date: Sat, 12 May 2012 01:57:48 +0100
Message-ID: <1336784268.8274.487.camel@deadeye>
References: <1333360929-31506-1-git-send-email-srinivas.kandagatla@st.com>
	 <20120403.184937.744089580257691570.davem@davemloft.net>
	 <20120509072537.GA437@burratino>
	 <20120509.115729.1982766903625560504.davem@davemloft.net>
	 <20120509171847.GC4884@burratino>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MuqNu8Az9BnC/fZ1SGn9"
Cc: stable@vger.kernel.org, David Miller <davem@davemloft.net>,
	srinivas.kandagatla@st.com, netdev@vger.kernel.org,
	peppe.cavallaro@st.com
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38681 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755061Ab2ELA6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 20:58:03 -0400
In-Reply-To: <20120509171847.GC4884@burratino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MuqNu8Az9BnC/fZ1SGn9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-05-09 at 12:18 -0500, Jonathan Nieder wrote:
> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> Date: Mon, 2 Apr 2012 00:02:09 +0000
>=20
> [ Upstream commit b3300146aa8efc5d3937fd33f3cfdc580a3843bc ]
[...]
> David Miller wrote:
> > From: Jonathan Nieder <jrnieder@gmail.com>
>=20
> >> I'm guessing 3.2.y needs this, too, since it also includes
> >> v3.2-rc1~129^2~247 ("net/phy: add IC+ IP101A and support APS").
> >>
> >> Here's a quick backport made by adjusting the context line to
> >> use IP101A_APS_ON instead of IP101A_G_APS_ON.
> >>
> >> Please include it in some later stable update if appropriate.
> >
> > Please submit this directly to the stable list.
>=20
> Thanks for looking it over.  Doing so.
[...]

I've queued this up, thanks.

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-MuqNu8Az9BnC/fZ1SGn9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT621jOe/yOyVhhEJAQr8ew//Uogqh6nOMvCfLH7bnp3LQhAlv48mt+1r
MREPEjruGepDcuXhjxe0cK1p7a6trncfajXBrab0ukTqNkDVEp/Fmi8GJWffzCy1
gVwHDyhmfctwF4M+tVVBZjAkXGJdkX2bfE72lrUzcnXJ5ZbeKny/P5QPQD7gYC9Z
JUDJX/PUgKYc5DQxT7N6S6gFVTaEw3+KnDwgAK6wOzQCv6eyyqh9bKTkZP3lxIkO
5e045Ue4k5Mv/RXuEIhKwWpS9q20qwECQ4Mvc6YHK++ANRUIuSAwsQ69VwzlLFkM
9M6OHS8FI2ELF6TAjon26B2DGHr87ujbmbT6bUB/vz2bGByasibCtvrcd9SJK++D
Gc0wUVwZ1mc0VMMpqza+wkuxo72JHe75qKf5ALv5hnLEMeHzeChDyPAYj3ybKIpt
MK75nQx7V3F3ihzNJmjE5KJHB/nMJEa7757gNbnGIxEvEGT0eLDRVifmltk6vggS
NM1LfQztMrMW1j8IAUheWOvTqlwzXEOIV3y3SaiOPSGF75mtvIrnUXLpZpxV7Oa2
aDhlnKP6TWg6pkp6dNVROeoZHmdpRchRPyt0m8KLw6wf+ORidbePAZAoe08PKFMH
ovlydCKoKa9+wDuQL07+bhpMaKBChsOHJDSwpYe8LNsZJyDEEho3Sqse6F0LvVOq
fPpNt2DkDEU=
=99FN
-----END PGP SIGNATURE-----

--=-MuqNu8Az9BnC/fZ1SGn9--
