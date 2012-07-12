From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [trivial PATCH 2/7] ixgbe: remove unused #define
Date: Thu, 12 Jul 2012 12:58:30 -0700
Message-ID: <1342123110.1783.83.camel@jtkirshe-mobl>
References: <1341959492-31389-1-git-send-email-jdmason@kudzu.us>
	 <1341959492-31389-2-git-send-email-jdmason@kudzu.us>
	 <1341960208.3336.43.camel@jtkirshe-mobl>
	 <1342116938.1783.57.camel@jtkirshe-mobl>
	 <CAPoiz9wcj7tbgVUf+D=HdonXnaMYFHb+TmSb77f2R2mpwGQM7g@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ux2wp4co9mXK8xyPo1CN"
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPoiz9wcj7tbgVUf+D=HdonXnaMYFHb+TmSb77f2R2mpwGQM7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Ux2wp4co9mXK8xyPo1CN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-07-12 at 12:49 -0700, Jon Mason wrote:
> On Thu, Jul 12, 2012 at 11:15 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > On Tue, 2012-07-10 at 15:43 -0700, Jeff Kirsher wrote:
> >> On Tue, 2012-07-10 at 15:31 -0700, Jon Mason wrote:
> >> > Remove unused IXGBE_INTEL_VENDOR_ID #define
> >> >
> >> > Signed-off-by: Jon Mason <jdmason@kudzu.us>
> >> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> > Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >> > Cc: Bruce Allan <bruce.w.allan@intel.com>
> >> > Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> >> > Cc: Don Skidmore <donald.c.skidmore@intel.com>
> >> > Cc: Greg Rose <gregory.v.rose@intel.com>
> >> > Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> >> > Cc: Alex Duyck <alexander.h.duyck@intel.com>
> >> > Cc: John Ronciak <john.ronciak@intel.com>
> >> > ---
> >> >  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    3 ---
> >> >  1 file changed, 3 deletions(-)
> >>
> >> This should also go through David Miller's networking tree's.
> Adding
> >> netdev mailing list.
> >>
> >> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> > After looking at this further, I rescind my ACK.
> >
> > NAK, this define is used in several places in ixgbe_main.c and the
> > driver will not compile with this patch.
>=20
> My apologies, I was a bit sloppy and simply rebased my old patches
> without retesting them.  The code has changed since I originally
> pushed the patch (http://www.spinics.net/lists/netdev/msg171523.html).
>  I will fix and resubmit.
>=20
> Thanks,
> Jon=20

Also note, that when you fix up the patch and resend it, could you
resend patch 1 (ixgb) as well to netdev@vger.kernel.org.  That way
netdev patchwork will pickup the patches and I can get them into my
queue.

Thanks!
Jeff



--=-Ux2wp4co9mXK8xyPo1CN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP/yxmAAoJEOVv75VaS+3OaAwQAIEpZkq72fyAT0Nt0mtJiYhP
KyhaX1oevPrEibEKI+Dz8TvKK1SFidhprNxRvSTn9zilq9gxAOmTGbMOUvIKdhBE
H2fhGJoFf0IaVYso/adBR/BZJwOg+gN1ahaCAZ8VRHtwUMvYaHu+lAZ5BBvkWsy2
UjSgfr9nbpoey7MPSRWs+1Yi5EkkgAJCb8hGGRXvyLgw5jsPrnfIcl83mB9Dk61H
Q7I/zMsFbAl8TIaLxAv5SEbUmWFeQcJ5oXWQuQjw+oBZFXuTXQEeDnqPM7MO3mEM
zjEnoFNRIZFkBbh7JRmzvT+enFWhgkuVQd1GX52GSdCZKhJmHP6KddNdZFlFag+g
8IK7gCa72Rjw2zVTCU0lh3LUkr7pj2Vm7FpyFElh14nDq8ALmwzFUxbUlvdLWSKi
lqCR2C03OFIiHrH0polBDDOEaqfWRnyppd5BbZVMu7PJZzSTwuoeOBCZD3lBtfF9
PecQe7NthR/bY0/myFIeqLq9jysVsXMPHuuHYMctwbfPaC+Wo1vWx7eJ8mqpzFHM
TKylbOu0Y7W595fD5GhG3zaDlvWNllZi414s2T9STx63lAvTW8N1EDX1fEY64fE9
rVoO954nV9QPNixvHMqM+aewlNUOLYE1kl0JenibR0pUGl3EJnxbDBnl2kcNaDTG
2jQColCgEpssSNM5sIyp
=K9sK
-----END PGP SIGNATURE-----

--=-Ux2wp4co9mXK8xyPo1CN--
