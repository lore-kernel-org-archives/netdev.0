From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: RFC: Network Device Driver Group proposal
Date: Mon, 24 May 2004 15:41:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524194117.GW3330@ruslug.rutgers.edu>
References: <20040524084945.GP3330@ruslug.rutgers.edu> <20040524113919.3651c453@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CwciIYoKw+3ryeRd"
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040524113919.3651c453@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--CwciIYoKw+3ryeRd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 24, 2004 at 11:39:19AM -0700, Stephen Hemminger wrote:
> On Mon, 24 May 2004 04:49:45 -0400
> "
> > OSLD wants to be the "center of gravity for all Linux related stuff". W=
ell
> > maybe OSDL can help us :)
>=20
> OSDL does have the ability to host Special Interest Groups (SIG's).  Ther=
e are
> two existing SIG's one for security, and another for storage.  It would m=
ake
> sense to have one for networking, as well. I held off proposing one becau=
se
> Jeff and Dave to a good job and it would end up being more work for me
> as the networking engineering contact at OSDL.
>=20
> There are no membership restrictions for SIG's at OSDL, but there are some
> rules (which are still being discussed). Mainly, they revolve around maki=
ng
> sure that everything is open, etc. There is a relationship back to the
> existing working groups as well.  For example, the networking SIG would
> be responsible for giving a response (positive or negative)
> to any networking requirements that came out of the CGL/DCL/DTL initiativ=
es.  =20
>=20
> So if Jeff (and/or Dave) want to have a networking SIG, I can get it star=
ted.=20
> Probably there needs to be a strong reason to add more organization to a=
=20
> already mostly functional process.=20

I think the netdev list is great. In fact, it's superb. But I think network
driver developers need more than a list. I think it'd be great if we had
a central group that can serve as resource for legal issues, one which
would act as a central group to which manufacturers/companies can give
NDA'd docs to (if this is acceptable; not like I like NDAs) and the
group could then provide those specs to developers which would then work
on drivers. Basically I feel we are doing great but we're lacking that
*corporate* entity any commercial operating system has. Who do
manufacturers seek out to provide/sell source base/NDA's to so that a
driver can be written for our OS? No one... On behalf of who does a
kernel hacker send out an e-mail to a company requesting specs to write
a driver? The DRI/Xfree86 project have an advantage because of this --=20
they represent a group who has done tons of great work and companies=20
tend to trust groups more than individuals. Of course, many companies
are now just takig the initiative to write their own drivers and then
send 'em away for kernel inclusion. But -- not all do this. An open
driver needs a mantainer.=20

Having a central place for network drivers would be nice for bugtracking
as well. Perhaps providing hosting services for network drivers may be a
good idea too. There are just ideas. I just feel something is missing.

If no one has time, I can work on it. I just want to know if this all
makes sense to others too. Don't *not* reply just because you don't=20
have the time. The work will get done if its for the good.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--CwciIYoKw+3ryeRd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAsk/dat1JN+IKUl4RAinmAJ46YriGGlI7VkDgOMhSkwtB5jEoRgCgsFGa
ZsU9hUVfRzVrSU2hAQCjV6Y=
=qhxc
-----END PGP SIGNATURE-----

--CwciIYoKw+3ryeRd--
