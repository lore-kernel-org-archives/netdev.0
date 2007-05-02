From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: Natsemi DP83815 driver spaming
Date: Wed, 2 May 2007 09:22:13 +0100
Message-ID: <20070502082211.GD31630@sirena.org.uk>
References: <20070501084639.GA528@sirena.org.uk> <46371590.4090004@interia.pl> <20070501180830.GA31630@sirena.org.uk> <46379A7E.3000109@interia.pl> <20070501212750.GC31630@sirena.org.uk> <b3ece790705011543gdca3a9ei905d3499b6c18dc8@mail.gmail.com> <46382798.2090709@interia.pl> <b3ece790705012303x1e5a2d03xddf6c14aec5a99d8@mail.gmail.com> <463830E1.8080107@interia.pl> <b3ece790705012351g5c0ff8a6g9f2f350ff86f3319@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FFoLq8A0u+X9iRU8"
Cc: =?utf-8?B?UmFmYcWC?= Bilski <rafalbilski@interia.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tim Hockin <thockin@hockin.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:1624 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbXEBIWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 04:22:31 -0400
Content-Disposition: inline
In-Reply-To: <b3ece790705012351g5c0ff8a6g9f2f350ff86f3319@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FFoLq8A0u+X9iRU8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 01, 2007 at 11:51:41PM -0700, Tim Hockin wrote:

> I'm not sure what the right answer is.  The code was designed to do
> the right thing, and yet in your case it's broken.  Does it need to be
> a build option to work around broken hardware?  Yuck.

Without a system that really needs the original problem that was being
worked around it's going to be hard to see if the workaround still does
the job.  Given the nature of the failure I wouldn't be surprised if it
broke different things on every board that has problems.

How about a sysfs tuneable?  It's not nice but at least it's runtime.

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--FFoLq8A0u+X9iRU8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRjhKMA2erOLNe+68AQIcjQP+LTDTrSu3WKuiAAI4swDlo06iP3MfZFo3
N/1NgP23gXxkrPYnMjlPkjJOeTpbDDkdD2UdoheExSvNaJ069rdURIvnjanTe+52
ewJMpWYSNi5DZOgyMU1AlOcFN8OcKJ/bGSUl5aMPnGt5+/NdFAC7yIriCsgbbHFd
mrBKjDG4IMQ=
=o2XV
-----END PGP SIGNATURE-----

--FFoLq8A0u+X9iRU8--
