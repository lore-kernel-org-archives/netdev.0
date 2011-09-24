From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/8] pci: Add flag indicating device has been
 assigned by KVM
Date: Fri, 23 Sep 2011 21:41:39 -0700
Message-ID: <1316839300.2182.134.camel@jtkirshe-mobl>
References: <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
	 <1316762872.23371.88.camel@zakaz.uk.xensource.com>
	 <43F901BD926A4E43B106BF17856F0755019C518C0E@orsmsx508.amr.corp.intel.com>
	 <1316790220.23371.105.camel@zakaz.uk.xensource.com>
	 <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
	 <1316792710.2182.124.camel@jtkirshe-mobl>
	 <20110923164326.GA23363@phenom.oracle.com>
	 <43F901BD926A4E43B106BF17856F0755019C518D57@orsmsx508.amr.corp.intel.com>
	 <20110923180025.GA6251@phenom.oracle.com>
	 <43F901BD926A4E43B106BF17856F0755019C518E23@orsmsx508.amr.corp.intel.com>
	 <20110923190537.GA18850@phenom.oracle.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Fy/f0Ekr71/v4lF2I4kq"
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ian Campbell <ijc@hellion.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20110923190537.GA18850@phenom.oracle.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Fy/f0Ekr71/v4lF2I4kq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-09-23 at 12:05 -0700, Konrad Rzeszutek Wilk wrote:
> > > > Version 2 of this patch with the modified comment was just posted t=
o
> > > netdev.  Ian Campbell had mentioned that the Xen pciback driver shoul=
d be
> > > modified to use this flag but I don't believe any patches for it have=
 been
> > > created yet.
> > >=20
> > > http://marc.info/?i=3D20110729165446.GA6731@dumpdata.com
> > >=20
> >=20
> > I'm not sure who generated the patches to xen-pciback.  It wasn't me an=
d I couldn't tell from the links you provided who did generate that patch. =
 I don't see it now though.
>=20
> I provided it.
>=20
> And I asked for a git tree so I could double check that it actually
> worked as I don't have the full set of your patches.
>=20
> Can you provide me a link to your public git tree or just repost it once =
more?
> >=20
> > - Greg

You can pull my tree or David Miller's net-next tree.  Both have this
patch now.  Here are the URL's

David Miller's net-next tree:
git://github.com/davem330/net-next.git

My net-next tree:
git://github.com/Jkirsher/net-next.git

--=-Fy/f0Ekr71/v4lF2I4kq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOfV+DAAoJECTsCADr/EWUSQYH+wSh8j2x2hA3vFspANgiGVyg
fOl70GNCWqmZshqhcTMuGkBzOOGw+lhYdWpLHTlV6W9s9+Xnz7Q5tuAx4ZAB+5um
HRVKxGkE8YzdpYlHJxrOFs+OSk75B/PMh1hPgVjx3Gf7tdxteNNrvNxWwKbuXYi8
oqR0HGpsnyIsNi8cdThiuq5pvh0rIpWzRw69jB8c7Fu7X/M99HfpTpIbfiBgR/zD
WIaxGnv/USX7O3eG/X4bjlT6vhxIWLIjQHvQ4LHR5ygh3hZU7Cz1SljVapjeE5Hc
oHG+8wRvJckcY06S7o9Q26DA25b4ZK0StNjCM6vXqGb79q53HHecZiIBzIIn8L4=
=4sMe
-----END PGP SIGNATURE-----

--=-Fy/f0Ekr71/v4lF2I4kq--
