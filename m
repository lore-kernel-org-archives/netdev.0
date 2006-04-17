From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: softmac: semantics of SIOCSIWFREQ
Date: Mon, 17 Apr 2006 21:27:09 +0200
Message-ID: <1145302029.4116.14.camel@localhost>
References: <1145190888.6560.22.camel@localhost>
	 <20060417163759.GB28203@bougret.hpl.hp.com>
	 <1145299691.4116.11.camel@localhost>
	 <20060417190649.GA28534@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mQ1DFSYyxQ5laYAElkfq"
Cc: netdev@vger.kernel.org, softmac-dev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:11201 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751236AbWDQT1N
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 15:27:13 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060417190649.GA28534@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-mQ1DFSYyxQ5laYAElkfq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-04-17 at 12:06 -0700, Jean Tourrilhes wrote:

> 	Definitely. I was just pointing out that scanning behaviour is
> not dictated by current setting of the drivers (except when the
> hardware does it, cf. Ornoco).

Yeah, I was just repeating it for Ulrich :)

> 	For freq, it's simpler. In managed mode, it's never 'fixed',
> because the card/driver choose the frequency. In master mode, it's
> almost always 'fixed', because the user has to set the frequency. In
> ad-hoc mode, it depend in the node creates or not the IBSS.

But isn't that a detail the user shouldn't have to know? See, if a node
with a higher TSF joins the IBSS, then it gets to send out the beacons
for it, IIRC.

johannes

--=-mQ1DFSYyxQ5laYAElkfq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUAREPsCqVg1VMiehFYAQJcCQ//aeySdxtXKmYPyLa/Bvr4OhDWiZreE+6M
wc9i1MgoSWMaDQq7v5jtJ99LITJugrX9b1Bnh/tCk0V5q7dGNoDl2xC7FxDDdJGI
hGhd29IvUmDlpnJuC1NNHf5GqklthnRvjXnJJ3lKDgEa0XpYIazvntQyTI3wXTws
hBTBqr3WypJ0BJoN8S9YxrSD61mNJf1jtqXnH564oeyfX9EHMrHIe+GbUE4JN1Tw
+QCLJnZcElMDXzZkyV8iOMVVzvNNsf4hFp5tExFUrZnONACGnCnP2g5Twe3O2ax1
Sq7kVIR8K4EAh//ia3F+aunOT2wKEAbqKOx/W3qSTQhytMd9/YX1Tyv/iWjxfv+F
VsmJlKGPnmVFm9k5e6Q+wkPn5UIcCX4UrVdK9rgC1490IhpxQ65X8gNr/z5+0+jM
vqgkppq6I8GDeKhCirXqgPdM4UTef0kKUaoGLch144dKi9zC6PRcgaOSem/OOC5Y
7+T3IjwcI66lJdsbo1CzayTPMTuXJRTVzLTsWgAw21ga7UaaeM2poFI/onfrsMv/
YrQ3m+pcQglLdrnDM79sJPGqkeJ+iGC/Otc7Rlp+savJkPkGJ+DZevevvhPcmLQ4
HtRQ8uiu2Ha2TxDMDLiGSrwh8mUXdWMmfj5GlPOWJfjIeASdI6WnXI0yiq3keMGv
5lok/F7mOLA=
=MA71
-----END PGP SIGNATURE-----

--=-mQ1DFSYyxQ5laYAElkfq--

