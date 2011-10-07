From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: moving GIT back to kernel.org...
Date: Sat, 8 Oct 2011 10:10:18 +1100
Message-ID: <20111008101018.10adfac93cebb6dd9991de78@canb.auug.org.au>
References: <20111007.145703.842130763413648388.davem@davemloft.net>
	<20111007.155902.916470368193047875.davem@davemloft.net>
	<20111008094212.e3342930c1833f73ef602a3e@canb.auug.org.au>
	<20111007.184657.1471438956485710175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Sat__8_Oct_2011_10_10_18_+1100_JajEPzpHpzjU2GyD"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	netfilter-devel@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-ide@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20111007.184657.1471438956485710175.davem@davemloft.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Sat__8_Oct_2011_10_10_18_+1100_JajEPzpHpzjU2GyD
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Fri, 07 Oct 2011 18:46:57 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Sat, 8 Oct 2011 09:42:12 +1100
>=20
> > On Fri, 07 Oct 2011 15:59:02 -0400 (EDT) David Miller <davem@davemloft.=
net> wrote:
> >> git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc.git
> >> git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide.git
> >=20
> > You used to have sparc-next and ide-next (and the above used to be your
> > "current release fixes" trees) ...
>=20
> I've made a dummy sparc-next tree for you to pull from, thanks:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-next.git
>=20
> As for ide, I only plan to accept real bug fixes for that subsystem
> so I'll avoid creating an ide-next tree for now.

OK, I will use those trees from now on.

Also, I have decided to rename them in linux-next to match your names, so:

Was		Now
---		---
net-current	net
net		net-next
sparc-current	sparc
sparc		sparc-next
ide-curent	ide

and I have dropped the old ide (would be ide-next) tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__8_Oct_2011_10_10_18_+1100_JajEPzpHpzjU2GyD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOj4baAAoJEECxmPOUX5FEVasP+gMLmMa1BDMzFq5J10U2BlXV
y+/orHxcEBz77U5gw6WJGFeq30EK/Z4WQdjvMspRjM9poJ+2wPoco01yugGezRAH
+dwqOaV+ysD5loFuZYIYlW9PSvDd6889dcu5vbC5KaPjW1h/u59SswJSSdHYPwrI
Q/E2k1zYHanOZyeOw9I+/CN/jWGRkk2SV31y8BdS9807RyFogqvgqO8d26/aaZC9
KNbC3q46QWDkBH8gZYCwei1jsssbu+LdSqGi1Ex/URMaD9uqNBI2qjAQuonH4RYL
Ey87To8MSjThfRpFCjPNLxZ10gnwZwybdNEc85ndeby3bczQ4LnX8qRbj4u7Hfpa
6tDsIFGddo3vZ14Q6GE+IItgOB8X73bAO6PO9yLisKargY+5S477//taAQOK0LHE
hDkVC0nBQFUaaSKwmgmL9huJ6ZwmktWnvmh11OB4feWExozbZtv7SENmxoRa3lFb
teNG/N7+8BLu47SkHl+7w0tyrn/PTA8iSVkVtkay5guicm9agMLlof5yxUw5rlGt
ELnLfZh1GgtVNkqtI/0yxgwE9mrOE025/Rk2cOgaGrkx+PtP8U/fWNhD6cdyAsA4
h6OMI5eygIuRk7WItREpd8Bt4YpH2HIjN4b8XQv6KeWeuOjuHCTgpR5DoyeP5daw
Y+ZV+CPy7yepCQ/KHZsn
=60qt
-----END PGP SIGNATURE-----

--Signature=_Sat__8_Oct_2011_10_10_18_+1100_JajEPzpHpzjU2GyD--
