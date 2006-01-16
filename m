From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 12:09:51 -0500
Message-ID: <20060116170951.GA8596@shaftnet.org>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost> <20060114011726.GA19950@shaftnet.org> <43C97605.9030907@pobox.com> <20060115152034.GA1722@shaftnet.org> <Pine.LNX.4.58.0601152038540.19953@irie>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751137AbWAPRK4@vger.kernel.org>
To: Samuel Ortiz <samuel.ortiz@nokia.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0601152038540.19953@irie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jan 15, 2006 at 09:05:33PM +0200, Samuel Ortiz wrote:
> Regarding 802.11d and regulatory domains, the stack should also be able to
> stick to one regulatory domain if asked so by userspace, whatever the APs
> around tell us.

=2E..and in doing so, violate the local regulatory constraints.  :)

Although I believe 802.11d specifies that the 802.11d beacons should=20
trump whatever the user specifies.  (of course, 802.11d doesn't say what=20
to do when there are APs out there that disagree...)

While I feel it should be *posisble* to do so, the default should be to
query the hardware for its factory default, and go with that.  Allowing
the user to change the regulatory domain at will.. is a rather fuzzy
legal area, to say the least.

 - Solomon
--=20
Solomon Peachy        				 ICQ: 1318344
Melbourne, FL 					=20
Quidquid latine dictum sit, altum viditur.

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFDy9NfPuLgii2759ARArdNAKDHarcySpv6JL4bOdWmvNpiyGPP7wCdHWur
Yfpl5FBIHoG342ZdhfM3S8A=
=h3cp
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
