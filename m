From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom
 load_pointer
Date: Fri, 2 Mar 2012 16:03:05 +1100
Message-ID: <20120302160305.c51a02c9fa5b11e191cd80e4@canb.auug.org.au>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<20120301233712.GS3990@outflux.net>
	<20120302114705.0a9542e138927897f16282ca@canb.auug.org.au>
	<CAGXu5jL0OXR5MOePFe=GT4_X5rdH8RNjQPqYXdbqsqfijUsEqA@mail.gmail.com>
	<20120301171914.7c64f095.akpm@linux-foundation.org>
	<eba2ab81bc32f208b8b94fd959fd7f2f.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__2_Mar_2012_16_03_05_+1100_CYpYzrlfOzNE7AjO"
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Kees Cook" <keescook@chromium.org>,
	"Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com
To: "Indan Zupancic" <indan@nul.nu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <eba2ab81bc32f208b8b94fd959fd7f2f.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__2_Mar_2012_16_03_05_+1100_CYpYzrlfOzNE7AjO
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Just a note.

On Fri, 2 Mar 2012 05:04:41 +0100 "Indan Zupancic" <indan@nul.nu> wrote:
>
> On Fri, March 2, 2012 02:19, Andrew Morton wrote:
> > That assumes that we're going to merge this stuff into 3.4 - if we
> > don't, unwrecker gets rewrecked and grumpy.
> >
> > I don't know if we're going to merge it into 3.4?  I haven't been
> > paying a lot of attention and haven't looked at the patches in a while.
>=20
> I think it should be merged, but I think 3.5 is probably better.

If it is going into v3.5, I don't want to add it to linux-next until after
v3.4-rc1 is out, thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__2_Mar_2012_16_03_05_+1100_CYpYzrlfOzNE7AjO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPUFSJAAoJEECxmPOUX5FE9vcP/jYJr2Qtnk6hXT/4xWkgm9TA
TI8RkimNlwTurTvOK4Bg4Kx7TnesHzj6IKdW0qjNkIlYTjKd08JDHrs02iLAHUjb
cCECHc9ecZzFfCRECdMSIwJ+WvxTeJhqzBM6QUP/HQsVv+A1SJEJlN41vMclJQ3n
W/etDwo+wehWSbyVdUPII7zyvB+WL3DEwXenroQdMpPTqiqN/nS5+uEg3KJ+kHnO
wdFmwGLadEGfBCWLDCQR5/Z88AYaOZ6clXg1y7V+tOfM4cQ4PlS96WZcyk9yAEic
fR9iLGZHMe+6j1TvyeqRgSai0LB3G+3oABUzsoJZ8Ruz7zSJbdK4/1Yq3P3dkdOa
mYmk+n2QK+E7+5Nj2ywL1C0DLkLr0JTHx8RjJ2vpGS41w0VdjPza/VmYfW/8qtJG
p1ZWWGHXCjhkIg/Im33kPWty4WHf05SgjeeucWEANTJj1LEKaizJBdTituIqX2kE
KWf62QvRDD3QjpQrLmic9Uap3l+//Rhq2gVpZWtLG1/dQLgvGaTRreGaFyaIj2jz
1xKtAHh5TxzK2oRAtotOhqH+8zMYG7RBh5M8y+wO6q3DP4fx48RfboBScFEPPtsy
l8lS4JSgNOAG8XJnh8jqREpE5ASlAKB07co9nBs5g0HtfhSNlzx9pRHiHtJrhJgO
WyIUzPaNPhKuRkE55pa6
=OWc2
-----END PGP SIGNATURE-----

--Signature=_Fri__2_Mar_2012_16_03_05_+1100_CYpYzrlfOzNE7AjO--
