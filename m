From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: add new emac_regs struct from driver, add new
 chip types.
Date: Fri, 09 Oct 2015 03:24:02 +0100
Message-ID: <1444357442.2956.290.camel@decadent.org.uk>
References: <20150923144634.2ea2bce9@fr-ThinkPad-W520>
	 <20150925081545.26cbb101@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cRyadbCUCzYt6lbDCkhz"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ivan Mikhaylov <ivan@ru.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150925081545.26cbb101@fr-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cRyadbCUCzYt6lbDCkhz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-09-25 at 08:15 +0400, Ivan Mikhaylov wrote:
> * add new version of emac_regs struct from driver structure perspective
>   and passing size from actual struct size, not from memory area variable
>   which set in dts file.
> * add three types of network chips for new struct : emac, emac4, emac4syn=
c.
> * add emac4sync processing in print_emac_regs.
> * this commit fixing problem with output of MII sections for new driver v=
ersions.
[...]

Applied, thanks.

Ben.

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.
--=-cRyadbCUCzYt6lbDCkhz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVhclQue/yOyVhhEJAQr3WBAAvahJDJqHhE7YtJ2FbIPXmGU7scby1JKQ
rBELMJV/LiBNpAjfjFxt87A5FfZhCHgOks5SwCpPOCyqFV6xvre7uBE7PYkIFtZh
V9FE+A1ma5W7SL4zUvzzI2/yYzL0YIf+l81lHRqdN7lM5+sHrJho68vi1sfJ2cyz
HXCYa3g5+8JG8HDJJ29R8ZObl6Y/51th9/DFo2KySVBuLhAqMgOhzgb/xX74RICi
HIfOcGUzG2hd9R3FnwrYUnD09VEdnmEKkkRzsDLW5vG60z8WhYgwXmRJSHMd+9In
8h7T/zRUVt7CTNFXU+mYntKKkoKRUWhO3r3A8RbwTvjo0ZBrwh7YooTISsRmlX/r
kfAh1nyFUyB/PtYW5iGZjrtq8Hb1nWZe2fdPPjnvymsEwA0rjK0yVvinkkoXO5+o
dfPxD/pMC8tuS4/1BycMzStAz/uHemkFGjYMBNUYEtwnKQEDm1W2rBZurwXRirbz
Z9gH54a3ZS8PCwc6YLQSPNbCc5QHzY3/VYNieni8Nvyae25k1qNWBJSa/cSBPbBd
m6zNryRzsRXbYM0mqfRNa1WeudZy45Czaxi9oJfPjPGNs96/ODaSCOgLaNSp6EFi
sS1OztO6O2zuHZfOeNE+oGAYoqXWXznsgItxTbTl37spgfsEGC3MwQ4ev31N6+UQ
G2FQbwTYU5o=
=W5gh
-----END PGP SIGNATURE-----

--=-cRyadbCUCzYt6lbDCkhz--
