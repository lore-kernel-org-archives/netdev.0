From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [RFC] acx100 inclusion in mainline;
	generic 802.11 stack
Date: Tue, 28 Sep 2004 20:48:08 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040929004808.GN30131@ruslug.rutgers.edu>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<413F70F0.6020709@atheros.com>
	<20040928122028.GK30131@ruslug.rutgers.edu>
	<200409282229.53349.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0399501844=="
Cc: netdev@oss.sgi.com, jkmaline@cc.hut.fi,
	"Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>, jgarzik@pobox.com,
	hadi@cyberus.ca, prism54-devel@prism54.org,
	acx100-devel@lists.sourceforge.net, sam@errno.com,
	greg chesson <greg@atheros.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <prism54-devel-bounces@prism54.org>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200409282229.53349.vkondra@mail.ru>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============0399501844==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OwXh6gFRjCd3qPCM"
Content-Disposition: inline


--OwXh6gFRjCd3qPCM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 28, 2004 at 10:29:48PM +0200, Vladimir Kondratiev wrote:
> On Tuesday 28 September 2004 14:20, Luis R. Rodriguez wrote:
> LR> RFC: what are the chances we can implement our own generic "softmac" =
that may
> LR> be usable by the different chipsets out there?
>=20
> Coming days, I will submit "framework" consisting of stack based on Dave'=
s=20
> code and debug driver which will be able to imitate Rx. I have working ba=
sic=20
> Tx/Rx. Then, I'd like to concentrate on interfaces stack-driver and=20
> stack-upper layers. It would be great if someone will do MAC algorithms. =
I'll=20
> appreciate this for sure.

But would it be possible? Would it work, if we write our own softmac
interface? Or are softmac interaces/libraries strictly dependent on a
chipset being used?

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--OwXh6gFRjCd3qPCM
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBWgZIat1JN+IKUl4RAn8AAKCDiw8wWMQF04IZBAlcEBhSvqGZuQCdEacr
jGiIIsQzZ7YanJksfluH37Q=
=hT92
-----END PGP SIGNATURE-----

--OwXh6gFRjCd3qPCM--

--===============0399501844==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0399501844==--
