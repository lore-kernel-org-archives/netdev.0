From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH RFC 00/73] tree-wide: clean up some no longer required
 #include <linux/init.h>
Date: Wed, 22 Jan 2014 18:00:23 +1100
Message-ID: <20140122180023.dd90d34cba38d9f9ac516349@canb.auug.org.au>
References: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__22_Jan_2014_18_00_23_+1100_zcOtMRV1NI/h=88n"
Cc: <linux-kernel@vger.kernel.org>, <linux-arch@vger.kernel.org>,
	<linux-alpha@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-ia64@vger.kernel.org>, <linux-m68k@vger.kernel.org>,
	<linux-mips@linux-mips.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-s390@vger.kernel.org>, <sparclinux@vger.kernel.org>,
	<x86@kernel.org>, <netdev@vger.kernel.org>, <kvm@vger.kernel.org>,
	<rusty@rustcorp.com.au>, <gregkh@linuxfoundation.org>,
	<akpm@linux-foundation.org>, <torvalds@linux-foundation.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-alpha-owner@vger.kernel.org>
In-Reply-To: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-alpha-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__22_Jan_2014_18_00_23_+1100_zcOtMRV1NI/h=88n
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Paul,

On Tue, 21 Jan 2014 16:22:03 -0500 Paul Gortmaker <paul.gortmaker@windriver=
.com> wrote:
>
> Where: This work exists as a queue of patches that I apply to
> linux-next; since the changes are fixing some things that currently
> can only be found there.  The patch series can be found at:
>=20
>    http://git.kernel.org/cgit/linux/kernel/git/paulg/init.git
>    git://git.kernel.org/pub/scm/linux/kernel/git/paulg/init.git
>=20
> I've avoided annoying Stephen with another queue of patches for
> linux-next while the development content was in flux, but now that
> the merge window has opened, and new additions are fewer, perhaps he
> wouldn't mind tacking it on the end...  Stephen?

OK, I have added this to the end of linux-next today - we will see how we
go.  It is called "init".

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgment of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
	Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

Legal Stuff:
By participating in linux-next, your subsystem tree contributions are
public and will be included in the linux-next trees.  You may be sent
e-mail messages indicating errors or other issues when the
patches/commits from your subsystem tree are merged and tested in
linux-next.  These messages may also be cross-posted to the linux-next
mailing list, the linux-kernel mailing list, etc.  The linux-next tree
project and IBM (my employer) make no warranties regarding the linux-next
project, the testing procedures, the results, the e-mails, etc.  If you
don't agree to these ground rules, let me know and I'll remove your tree
from participation in linux-next.

--Signature=_Wed__22_Jan_2014_18_00_23_+1100_zcOtMRV1NI/h=88n
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS32yLAAoJEMDTa8Ir7ZwVm18P/i9+tdEJe4LadVgjePUgRka0
guzWVBgQs96hVeg/7h+LJWNRsMgu90m1S6n0BhoA/maJqSb1zHJ5VhWbPuDkCdRo
EEB1J/lW35ziCkBg+ejAQm1c+5QIsoyi0MbuFEGyX7a8FgFJrzC3bJCQCysNHsxR
mKYtXKdpPzpluxSzjCdecZyfWA6SU3Lbvgh6Th3yyQaAlm/QOk/k3wGGvQND/ODS
37ktKXITCAnhCZ6HvVanJvim6pK78dDJPL1h7yVZ/heYJbEqEONfFuHeg+j1RVZg
ilcnhvmkg6jEJoQkHB+ZopLVwv+QEnkPxzDPwmNNcAIexxvHXXpOkc3geeWtNsHp
NNvJFXIWMbzemktgVNM3r5uxgnPmAcHCU6vaZTv/kodSZDuGrkvbOscwEpNyr1Bw
rVm5gSiLyfA8eecFymGhPXvPvrAbmcA11lxZCh0V4gmgC5eKrUwiTIFGhm6n9WCy
FartKLucuqCzLOgLujCC+c+7BOwTjc1vyMBbQtBwSCfPc/tyZZLvI9QTyv3tJKro
G4Jimb7wth9sm93N7n9uplshLbNrNvTbE3Q9OU+mOKMzj0uD9ck/htxfh1vEZKWd
vfuOCJrgnQdOA/TeZQmlKfIy/t2hkJXAV/oipKVrGg45oJZB72Tt7BA4FhUi/PeE
2qfphmmDreRrUP/I4bqp
=j4pk
-----END PGP SIGNATURE-----

--Signature=_Wed__22_Jan_2014_18_00_23_+1100_zcOtMRV1NI/h=88n--
