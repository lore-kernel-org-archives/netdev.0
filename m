From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net v2 2/7] e1000: prevent oops when adapter is being closed
 and reset simultaneously
Date: Mon, 02 Dec 2013 18:22:33 -0800
Message-ID: <1386037353.2216.19.camel@jtkirshe-mobl>
References: <1385803221-3752-3-git-send-email-jeffrey.t.kirsher@intel.com>
		<529A145C.4030503@cogentembedded.com>	<529C57CE.1040801@windriver.com>
	 <20131202.111237.721028511867832463.davem@davemloft.net>
	 <529D3BC0.3020206@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xv57wZHPrp01hC8nEONj"
Cc: David Miller <davem@davemloft.net>,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, zhuyj <zyjzyj2000@gmail.com>
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25231 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597Ab3LCCW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Dec 2013 21:22:59 -0500
In-Reply-To: <529D3BC0.3020206@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xv57wZHPrp01hC8nEONj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-12-03 at 10:02 +0800, yzhu1 wrote:
> On 12/03/2013 12:12 AM, David Miller wrote:
> > From: yzhu1 <Yanjun.Zhu@windriver.com>
> > Date: Mon, 2 Dec 2013 17:50:06 +0800
> >
> >> Thanks for the advice from Sergei. I made a new patch with the name
> >> "yanjun.zhu".
> > That's not a properly formatted real name either, it should be somethin=
g
> > like Yanjun Zhu.
> >
> > How do you write your name on paper when it needs to be romanized?
> >
> > Do you write "yanjun.zhu"?  I doubt that you do :-)
> Hi, David
>=20
> According to the tradition and the regulations, my name should be "Zhu=
=20
> Yanjun" or "yanjun.zhu".
>=20
> Thanks for your advice.
> Zhu Yanjun

So before the next time you send a kernel patch, make sure
your .gitconfig has the following information:

[user]
	email =3D yanjun.zhu@windriver.com
	name =3D Zhu Yanjun


--=-xv57wZHPrp01hC8nEONj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSnUBpAAoJEOVv75VaS+3OOlsQAKEQPtkfyvMZDHQYK5tHYVZQ
YPWkJAmBFWtlrIIWW2jvrN9OHR8MVO7y8amSac2JvNpwI4Yd1RWSWTyubSOGuG4a
y4Ow0ffrbFeZEfyjP5vmNtcevblKVy3t1u5BBEbVdyUAAmFtpRPIyVYk1l70P/gj
XdxDNc+sd1Xdh0KeUmPPjw7VxbLQQ6u/0YD/u34lOv3Uk0RRT2aYYnBPvuwGr3Kc
nT5tDZiN2AEFc3IxnPXudmmcnol0Gj0NhpGmOISRkrElF+GGZ+FQSRerZ1sNMmUi
GqKXUid8uD2MpXdJxn5eqXK94nLb8TMMC+CscOTd0LEh4f40Ihs+iAAcrDLelqym
0Auy/OyuwNUXEYHjGcrk6WmyoAQJqftNCCntuOeIfHgLKupsLF32SJATlM/pSwZO
49+2DIaffgKpuWpCx6eZ2wvjX7GUOtofBPBtPmQvNPqeTAiigg2LSP9gkZ/E2kaN
9dQV3KTMO1OaObDYTwkCl1CAABx+0fYyZwd0Na1p+w/Q1BJwWuGt2UzqaidPg9W1
NSzcNxiuwhjvbhOj1PBP+O5Y99/ZwT92lm5u0crW3PYypl6WlDNWGaqw6qLOegNW
+aVA6hrqoEzPJ+IwF7gxJRIchyHlx82fgACNKz/wqsoDeKSw7A8+aQYJ2B1o+ELn
GehxPhl/D+uzwryuBAUg
=fwS2
-----END PGP SIGNATURE-----

--=-xv57wZHPrp01hC8nEONj--
