From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [stable] [PATCH] be2net: Bug fix to support newer generation
 of BE ASIC
Date: Thu, 28 Jan 2010 23:20:28 +0000
Message-ID: <1264720828.373.552.camel@localhost>
References: <20100128075633.GA4785@serverengines.com>
	 <1264718429.373.520.camel@localhost>  <20100128225114.GA1588@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-PLoAw+JHRpB3waXK/6TG"
Cc: Ajit Khaparde <ajitk@serverengines.com>,
	netdev <netdev@vger.kernel.org>, stable-review@kernel.org,
	David Miller <davem@davemloft.net>, stable@kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41445 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753169Ab0A1XUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 18:20:34 -0500
In-Reply-To: <20100128225114.GA1588@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PLoAw+JHRpB3waXK/6TG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-01-28 at 14:51 -0800, Greg KH wrote:
> On Thu, Jan 28, 2010 at 10:40:29PM +0000, Ben Hutchings wrote:
[...]
> > Also, you should either send this patch to stable@kernel.org, or NAK th=
e
> > addition of PCI ids for BladeEngine 3 in 2.6.32.7.
>=20
> Why?  How does the pci id patch for 2.6.32.7 matter with this change?

Because it looks like the devices being added won't work without this.

Ben.

--=20
Ben Hutchings
You can't have everything.  Where would you put it?

--=-PLoAw+JHRpB3waXK/6TG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS2IbuOe/yOyVhhEJAQJx2g/6A5GHIAyf3kAQRcssnedc+JWdjdUYJnPs
W0ZQ2J8Czlj25oP5brTMFK+uczh4Yfy4AeEjxEdGMi2RBCznIw9F5ihHMu6hQmY0
1wcTjArTLj0IbywTsnNFxQxlcS6o5nrisgpFZjEgHNaOVuw0TVZXKN16+CSBbzAm
6elItn5tfB09/vfBaLuEr0H9MtjZNmvuhizr4+f0O2OwNE4qwIDaBzudT47l38bO
CvXyFMB7YRIUzRvzel6k822V8ZiNgnORXrlvNjwBqDur+WIMZjMPhXtm7Ry+HBzG
qGzAcroytCZ0OxJVTNSeQqEN0lir1O5GPBxF++0mYIVSzL/F179eUX36ysVW0J67
IMkeoDA5l5UntrILnV2Q6EXH3+uDVyuPKGxH3pKCLhRLzVNMcvVnJWD3b0Fxaugy
xjXHmIYSeDtb5F083Q6/UBVcUJSeAMIDQZA6sXk0EOKknqZi9Citxs6Gs2BlyOZZ
ag19ThWgPGj657Cr6XAOGUFguRdVZMlAcxkxRK3FW9q0myIzYq4Oy4f/c2ZRU65p
o+TlZAbuxCDqs5zhdWhgQ9hDZ5r1e4UqqJYhvv5EC41nXvoSP/NwgkzkbL6AtDMk
392B9N71KMuqnEC5WidSRF7sANKyaKmc37n/kHkG7O9kXRrPdBrZ8SazEof7ZB2+
5+2ek+ZRruM=
=4mu6
-----END PGP SIGNATURE-----

--=-PLoAw+JHRpB3waXK/6TG--
