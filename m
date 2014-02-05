From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT PULL] tree-wide: clean up no longer required #include
 <linux/init.h>
Date: Wed, 5 Feb 2014 17:27:23 +1100
Message-ID: <20140205172723.3fa841793b3fa3f3f534937f@canb.auug.org.au>
References: <1391547118-21967-1-git-send-email-paul.gortmaker@windriver.com>
	<CAP=VYLp+zus5591g-1YQBCJifbk+UY59yJ7rV06ZN3QhhdnK7w@mail.gmail.com>
	<20140205060633.GE30094@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__5_Feb_2014_17_27_23_+1100_gh/a8HjiUdsUGOqJ"
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	x86@kernel.org, linux-ia64@vger.kernel.org,
	linux-mips@linux-mips.org, linux-m68k@vger.kernel.org,
	akpm@linux-foundation.org, gregkh@linuxfoundation.org,
	rusty@rustcorp.com.au, linux-arch@vger.kernel.org,
	kvm@vger.kernel.org, linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-alpha-owner@vger.kernel.org>
In-Reply-To: <20140205060633.GE30094@gmail.com>
Sender: linux-alpha-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__5_Feb_2014_17_27_23_+1100_gh/a8HjiUdsUGOqJ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Ingo,

On Wed, 5 Feb 2014 07:06:33 +0100 Ingo Molnar <mingo@kernel.org> wrote:
>=20
> So, if you meant Linus to pull it, you probably want to cite a real=20
> Git URI along the lines of:
>=20
>    git://git.kernel.org/pub/scm/linux/kernel/git/paulg/init.git

Paul provided the proper git url further down in the mail along with the
usual pull request message (I guess he should have put that bit at the
top).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__5_Feb_2014_17_27_23_+1100_gh/a8HjiUdsUGOqJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS8dnPAAoJEMDTa8Ir7ZwVybEP/31Z6vmdSzqXa6CGStETJw23
6BXTjf+UbSse//B/vkCLZLm698gmOezpw5NCnCKkK/rYTSJoE89rKmPnXB9H+0mD
96PWZbw2vTR6TzU9Om85nOdui2ly7mMCvtg7d+U4vqGM4bRzetFxSM0YV3yCKYaq
J0xttn7NnVnhCJpLVOofz9ulsnygMG6Gn0TSOomANZsBUpxZotvgdWGRZWgg1oVF
MILuhwwwu0mbgf+a1SSWQvAChiuCP63vveXTiwvjT57lDlJXRODyl912lp0SyGug
7Av6juPn1van5sXsHVqba3GT+4qeWN4DQkq017KZlJ0lGUiPg3HLCxagUzY64NfX
HPEVmRBlDpFRgX8ivTJmV/hYkL0aVhTsnqubd+q6E2MH3szdU/Gf3GAo4Dl/7QnG
nnkSUN0RP93xnM6hEORgGwkSSoEM0E4dvgZeGkPBs223BaEPAL+JLnEgHTXGk8gI
muoC0oBA1DvmbTYp6UgLTSRdQZYfMb/IdpExQGpEd7lF2DfOOKqm3pcktcG7nCSs
AaNdRepdtAY9vc2ISzNunqXta4TsOpKI7YPXEFvcuciVmj0lXkdKLCkp/1xj3v9t
vupSRjKH9tocr8kOS3uc+i9T8wZkHZ5I0/LRNux8AVLAtLKUQeYAt6ZAyrsDvToM
xuVmB/iHm04LyVGRQ59z
=XhOK
-----END PGP SIGNATURE-----

--Signature=_Wed__5_Feb_2014_17_27_23_+1100_gh/a8HjiUdsUGOqJ--
