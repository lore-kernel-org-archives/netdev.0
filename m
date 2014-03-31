From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 07/14] i40evf: remove double space after return
Date: Mon, 31 Mar 2014 11:24:45 -0700
Message-ID: <1396290285.2158.2.camel@jtkirshe-mobl.jf.intel.com>
References: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1396015695-25283-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJZOPZ+NqT8LsJGjtmZGwUANONXphgtm1tZSdoLrRiDyruyJ0Q@mail.gmail.com>
	 <20140331104804.00005c55@unknown>
	 <CAJZOPZKSowPH4fB_QS3eXh2e9QFESKGaFfo9=x9gncE9bL8xAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2CGqkVK7YjXn4PC19QT5"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3455 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbaCaSZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 14:25:10 -0400
In-Reply-To: <CAJZOPZKSowPH4fB_QS3eXh2e9QFESKGaFfo9=x9gncE9bL8xAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2CGqkVK7YjXn4PC19QT5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-31 at 21:18 +0300, Or Gerlitz wrote:
> On Mon, Mar 31, 2014 at 8:48 PM, Jesse Brandeburg
> <jesse.brandeburg@intel.com> wrote:
> > On Fri, 28 Mar 2014 22:58:31 +0300
> > Or Gerlitz <or.gerlitz@gmail.com> wrote:
> >> Just out of curiosity, any special reason for four of the maintainers
> >> to sign on a patch that remove a space?
> >
> > Yeah, seems like lots of overkill, in this case it is just an artifact
> > of all the people that handled the patch as it exited our process.
> >
> > Thanks for the review.
>=20
> So beinh curios again, are you planning to change something based on
> this feedback and your overkill comment?

Yeah, I will ensure that patches I send out won't have an overkill of
signatures.  I saw this when I went to push it upstream and thought
twice about trimming down the list.  I plan on keeping the author,
tested-by and my signatures on the patch for sure.

--=-2CGqkVK7YjXn4PC19QT5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTObLtAAoJEOVv75VaS+3OCxYQAIIfDjqcn/bLtDr7lKreajYi
Vigq8zpee7pRIhbOReLEUdPNV8UG5cLFgEKZmS3CfIZEnLUyuNN1szAa2atQ8tb0
kF9fAHteis7367pJAUnfkX1V+S1wxt8LZeqCU6zkSVNfh5kxxlFDVb0MT3azaIKF
aLoKpU8Vrlew2FY51q0f0nR3GG78VcC/9l17VftYbwt8A0/9CUjnLIlOwYhi0YGa
cCKmvM69q6DA0C+ZiXbV0O+Fa47dqBbGM+hECFFC1R4rL2ceODZZR/REkxQ3Ptlo
h8XjZHFi/QvKgdYeoYoFoQPPVU3UJnYI1LxNeZfoG+KTs+Ru10tt2Gqsq3sDTDw9
Im2yqEJ24+KlZowmp7HI3F04JaRMIHc6Nxx7MgLDjLKUQXOBAFqxkPNHKB3bw1xd
2CVDjYDKRssw0b43T55V5DSf8crxLw6vVOmdkZN9cTWWoB1y7HkFMmj7UfCLoZwR
q5Woym/0HpQCyLy+em9icKUtJU8fP+A9g8LefYv1O51o/1MLxEZ1DGoLCFiGYRQu
wizTNpVkyfAl4XV8+rP7LyNSFEClwvsqAxvmJRmWXX1c9+ixy5ayp5ZKForgLAQL
ggjyiuWbyxmSayTavJpQ97jymKY72arXOYaaNvyYtDm7e5QoGGosEdnIxJXqNTdE
ZH7gwtyQE4TQJTsXHK7O
=7AxD
-----END PGP SIGNATURE-----

--=-2CGqkVK7YjXn4PC19QT5--
