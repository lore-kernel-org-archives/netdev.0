From: William Dauchy <william@gandi.net>
Subject: Re: loop on reset adapter with ixgbe
Date: Tue, 26 Nov 2013 14:00:54 +0100
Message-ID: <20131126130054.GC2849@gandi.net>
References: <20131120182524.GC16953@gandi.net>
 <F6FB0E698C9B3143BDF729DF222866466FD88708@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lCAWRPmW1mITcIfM"
Cc: William Dauchy <william@gandi.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Potenza, Leonardo" <leonardo.potenza@intel.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:60736 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754542Ab3KZNA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Nov 2013 08:00:56 -0500
Content-Disposition: inline
In-Reply-To: <F6FB0E698C9B3143BDF729DF222866466FD88708@ORSMSX110.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lCAWRPmW1mITcIfM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

Thank you for your quick reply.

On Nov20 18:53, Skidmore, Donald C wrote:
> Thanks for letting know what you're running into, however I don't remembe=
r ever seeing a failure quite like this.  I'm wondering if it is something =
we might have fixed in later versions of the driver.  By any chance could y=
ou see if you get the same failure with the latest source forge driver?  It=
 will make it easier to track down if we are looking for something we alrea=
dy fix or a new problem altogether.

I am unfortunately getting the same result with ixgbe 3.18.7 compiled
with a linux kernel v3.10.x

Sorry for my late answer,
--=20
William

--lCAWRPmW1mITcIfM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlKUm4YACgkQ1I6eqOUidQEHmACfXO3A9/ffjYyiPY5aG8XNDo7t
c4YAnAw81cgxotD3JZFCJJfx/fp0M1JT
=5Y0b
-----END PGP SIGNATURE-----

--lCAWRPmW1mITcIfM--
