From: Mark Brown <broonie@kernel.org>
Subject: Re: ipv6: fix headroom calculation in udp6_ufo_fragment
Date: Fri, 13 Dec 2013 13:14:45 +0000
Message-ID: <20131213131445.GA22789@sirena.org.uk>
References: <D00A5DFD97C44C4D820FC3A847C5D5750730630F@IRVEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Cc: 'Pravin B Shelar' <pshelar@nicira.com>,
	'Saran Neti' <Saran.Neti@telus.com>,
	"'David S. Miller'" <davem@davemloft.net>,
	'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>,
	'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'stable@vger.kernel.org'" <stable@vger.kernel.org>
To: Mark Hambleton <mark.hambleton@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:34917 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994Ab3LMNO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 08:14:59 -0500
Content-Disposition: inline
In-Reply-To: <D00A5DFD97C44C4D820FC3A847C5D5750730630F@IRVEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Dec 13, 2013 at 01:01:59PM +0000, Mark Hambleton wrote:

> Following a recent commit to LTS and upstream  I see the following
> warning emitted on an ARM32 build:

That's 024abeeced731 in LTS and 0e033e04c2678 upstream (ipv6: fix
headroom calculation in udp6_ufo_fragment).

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSqwhCAAoJELSic+t+oim9lBcP/3h04Y9tjt5oB8/gTqPwLj8t
Kuqk2WBc24n5RC1sMNOUJhwGjakitTjaSNgIxmm7Gq3iDRb9S7lQMlyNclX5ip0M
+zhLL/pgnzWBrYMfjlQSDINKzPf5hfs8K5WA3Lafjz/CDIDJ8LNbbrFNaefE68+1
wfbLcnxpaM0HXthBhx2+H+PQ3HJ24MaNsIHlyF26pMQzDziXvxfZGyXSOGwrk88T
1QNNwxA6yqsllaYgBCydvZ1C7AaZFT3o9F3EHbFPFZnhl94fvOcwltju3Ao0sS4d
pd4kfD6UbNfz3wTv6/xhpNDscKTA2hcAh8HF+VVEuTjwNtZPaVEIUJ51vu8oI065
YFngTu1Bw2Fl300yJ8ox1x+XkxZBvhIVDnfBK16hdjk7jERHxq9AqxdrIF1AyTFV
TQwixPO9OcgLRRJm8VlTX7614z41zsVx8vR1Rnq+QEKDtzHdtbmSGh1o262Ab+Gq
ul1S0xpBEP8CeEHVFWtdK+ZW0jgHhU6ZKLsu95Xnt9vOnTTOYzAuu7jS69bl1gWH
BRhuW2o+Ac1cgeN+2JlcYyMLb9qYWGfuu1x5LPNIia9P1q07OTmYidmrsQllIOAj
IOK9xk9HEJRl70oZx5yRm3SkMKovhiAOiTjvYVMC2/0gin1Qat4IYXCSasTA8h90
0L8oPGs0U7hPjIRspYVk
=jlog
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--
