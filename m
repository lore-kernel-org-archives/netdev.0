From: Tom Duffy <tduffy@sun.com>
Subject: Re: [PATCH][v3][17/21] Add IPoIB
	(IP-over-InfiniBand) driver
Date: Mon, 13 Dec 2004 10:54:29 -0800
Message-ID: <1102964069.9258.20.camel@duffman>
References: <20041213109.JT1ejUdkRIUXbWOm@topspin.com>
	<1102963464.9258.11.camel@duffman>  <52mzwi58zj.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2128318418=="
Cc: netdev@oss.sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52mzwi58zj.fsf@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


--===============2128318418==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-Yk6Oa+xZH+Icmf/OE6Jd"


--=-Yk6Oa+xZH+Icmf/OE6Jd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2004-12-13 at 10:49 -0800, Roland Dreier wrote:
>     Tom> Is there a reason why you put this in in an earlier patch and
>     Tom> then take it out later?
>=20
> I guess the reasons are stupidity and bad patch scripts...
>=20
> Doesn't hurt for now, will be fixed in future versions.

Speaking of nits, there are also some formatting issues with the
Makefiles that changes in the later patches...

But, the end result is you get the "correct" formatting if you apply all
the patches.

-tduffy

--=-Yk6Oa+xZH+Icmf/OE6Jd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBveVkdY502zjzwbwRAkGbAJ9Y7nYIijNZSAB28LyYyB6UeuopUgCgokCn
V7J0vqX7XrxA2MFpGbBVJ2g=
=xZFZ
-----END PGP SIGNATURE-----

--=-Yk6Oa+xZH+Icmf/OE6Jd--

--===============2128318418==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2128318418==--
