From: =?ISO-8859-1?Q?H=E5kan?= Lindqvist <lindqvist@netstar.se>
Subject: Re: 2.6.21 known regressions (v2) (for -stable team)
Date: Tue, 01 May 2007 00:35:15 +0200
Message-ID: <1177972515.9204.12.camel@localhost.localdomain>
References: <463375E5.5040108@googlemail.com>
	 <20070430143057.41ec75db@freekitty>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=sha1; protocol="application/x-pkcs7-signature"; boundary="=-TQKIYnwZWcckSIeF0Maz"
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	stable@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org,
	Riccardo Ricci <rricci@nuovanetmore.it>,
	"Udo A. Steinberg" <us15@os.inf.tu-dresden.de>,
	Len Brown <len.brown@intel.com>,
	David Brownell <david-b@pacbell.net>,
	Jeff Mahoney <jeffm@suse.com>, reiserfs-dev@namesys.com,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	Francois SIMOND <curio@free.fr>, netdev@vger.kernel.org,
	Vincent Frentzel <zcecc22@ucl.ac.uk>,
	=?ISO-8859-1?Q?Fran=E7ois?= Valenduc
	<francois.valenduc@skynet.be>, Thomas Meyer <thomas.mey@web.de>,
	Giorgio Lando <patroclo7@gmail.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422800AbXD3WfW@vger.kernel.org>
In-Reply-To: <20070430143057.41ec75db@freekitty>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-TQKIYnwZWcckSIeF0Maz
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-04-30 at 14:30 -0700, Stephen Hemminger wrote:
> > Subject    : 2.6.21: sky2 "hw csum failure" problem
> > References : http://lkml.org/lkml/2007/4/28/105
> > Submitter  : H=E5kan Lindqvist <lindqvist@netstar.se>
> > Status     : unknown
> >=20
>=20
> This is not a "regression" it is a bug, that has shown up for
> some users for quite a while, see:
>  http://bugzilla.kernel.org/show_bug.cgi?id=3D7579
>=20
>=20

It's not a regression in 2.6.21, but it is a regression as there is an
earlier kernel version where the sky2 driver works properly with this
card.


To me it doesn't really matter which way the problem is classified. I'm
just hoping that there will be a chance of moving past 2.6.16 on this
machine at some point.


Regards,
H=E5kan Lindqvist

--=-TQKIYnwZWcckSIeF0Maz
Content-Type: application/x-pkcs7-signature; name=smime.p7s
Content-Disposition: attachment; filename=smime.p7s
Content-Transfer-Encoding: base64

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


--=-TQKIYnwZWcckSIeF0Maz--
