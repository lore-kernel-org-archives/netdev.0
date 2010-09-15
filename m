From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 00/15] change default_llseek action
Date: Wed, 15 Sep 2010 19:39:26 +1000
Message-ID: <20100915193926.ae2fe838.sfr@canb.auug.org.au>
References: <1284495763-7506-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__15_Sep_2010_19_39_26_+1000_DQXdvYbRSl_dI/ss"
Cc: linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org, Jeremy Kerr <jk@ozlabs.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Julia Lawall <julia@diku.dk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org,
	linuxppc-dev@ozlabs.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	Tony Lindgren <tony@atomide.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284495763-7506-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__15_Sep_2010_19_39_26_+1000_DQXdvYbRSl_dI/ss
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Arnd,

On Tue, 14 Sep 2010 22:22:28 +0200 Arnd Bergmann <arnd@arndb.de> wrote:
>
> Stephen, please add
> git+ssh://master.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git llseek

Added from today.

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

--Signature=_Wed__15_Sep_2010_19_39_26_+1000_DQXdvYbRSl_dI/ss
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMkJROAAoJEDMEi1NhKgbsYp0H+wXse/dv0zaLotuqwSwNBEwU
pGyUJJlbgnsQrSCuQ0RowdoQ0djjfK9vpruhdv82egNE/g/Fce/cGx7W4VH1danv
kAEkH42TGgqfbRZ2/bzxBNrewRNLZWd35RPHraMbuYWifGWvrvcY0XqbXL8shP1a
7yQhIdm7yhETa0pCWNgNr96Uxm6zn5Dh6VcF7ux+CoabO9OJ/UTHwnS9YSg2Jq8V
IY9XXeTrwUbKHiZlBTyLXqexe74h04hK5Dl6xz1+PQw+cLnwwgX07lNa+MzEMeLC
FnQcuYnjVedEKfJvTdO4omXXPscchuPj1fJAAVs6jD8/2n4/+fA6nY6UNCKzN9k=
=B+lf
-----END PGP SIGNATURE-----

--Signature=_Wed__15_Sep_2010_19_39_26_+1000_DQXdvYbRSl_dI/ss--
