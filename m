From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/7] IB/hfi1: use pcie_flr instead of duplicating it
Date: Wed, 26 Apr 2017 15:10:25 -0700
Message-ID: <1493244625.2124.6.camel@intel.com>
References: <20170414191131.14286-1-hch@lst.de>
         <20170414191131.14286-6-hch@lst.de>
         <A33E225544E47D4DB5713032774B132783960382@irsmsx105.ger.corp.intel.com>
         <20170424143507.GA28812@lst.de>
         <20170425193955.GC29024@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-jIG6ReGmICyr8JtIFsUq"
Cc: "Byczkowski, Jakub" <jakub.byczkowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "Cabiddu, Giovanni" <giovanni.cabiddu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Benedetto, Salvatore" <salvatore.benedetto-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Marciniszyn, Mike" <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Dalessandro, Dennis" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Derek Chickles <derek.chickles-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Satanand Burla <satananda.burla-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Felix Manlunas <felix.manlunas-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Raghu Vatsavayi <raghu.vatsavayi-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        qat-linux <qat-linux-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linu
To: Bjorn Helgaas <helgaas-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170425193955.GC29024-1RhO1Y9PlrlHTL0Zs8A6p5iNqAH0jzoTYJqu5kTmcBRl57MIdRCFDg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-jIG6ReGmICyr8JtIFsUq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-04-25 at 14:39 -0500, Bjorn Helgaas wrote:
> On Mon, Apr 24, 2017 at 04:35:07PM +0200, Christoph Hellwig wrote:
> > On Mon, Apr 24, 2017 at 02:16:31PM +0000, Byczkowski, Jakub wrote:
> > > Tested-by: Jakub Byczkowski <jakub.byczkowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >=20
> > Are you (and Doug) ok with queueing this up in the PCI tree?
>=20
> Applied this with Jakub's tested-by and Doug's ack to pci/virtualization
> for v4.12.
>=20
> This still leaves these:
>=20
> =C2=A0 [PATCH 4/7] ixgbe: use pcie_flr instead of duplicating it
> =C2=A0 [PATCH 6/7] crypto: qat: use pcie_flr instead of duplicating it
> =C2=A0 [PATCH 7/7] liquidio: use pcie_flr instead of duplicating it
>=20
> I haven't seen any response to 4 and 6.=C2=A0 Felix reported an unused
> variable in 7.=C2=A0 Let me know if you'd like me to do anything with
> these.

Just provided my ACK for ixgbe patch.
--=-jIG6ReGmICyr8JtIFsUq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZARrRAAoJEOVv75VaS+3OlRoQAI8Y9SG9qJ9Z8GcmZX02HTc7
XngO312dcy+PZU1gLFqOXrBXjoXf0cWmvwNSHCzLFOvm5DI7qCpQ701yweewHWLC
D6x3JoeAeHJTCAvi2wSopOxMt7XZA4gJZSbvlvF+qlPt7D3qwq/AFOEMNasjR2qd
QOpJDvksHvIPMEW26oXqQuXpy+uIsEcEwzt8F1HgXg/EWP1KRRCCOd6aWR7Qa3yx
8ZMH9cCpT/C00hkK66XoUsAODF8P9aMLyZeuID6r+xqAYoG8ySSzilyt1DBUcZzM
/AUSxWhRM1rgg1/mxXVyzXU7ectAKv3gTjOWD9dgFzWyhQGqqhcyYWq1+WAy83gl
Ttu/aTV65BksmEA+l+QfYa5M+IH+xKPEOztxkeBk66V4nAFjXsvG5gcosAA8e8I3
W2wMLwaJuvIuSfUo1aol2oNp+UwDNIbToYTr+2Ah9KeH1uU+QW9ThPUkbxBOtJjh
LhYtVP41kbXhfuPKUUApW9f0uTNegC6TDXAkwmjyDyeAm9qJ0iOnBhBzx1WquzFA
VQx983bwWAXgiY36qh1KlKpuq4wRrkI2wFGavVbWz1qqthXQ+Q6tM4dHOLfRCIKs
T15dhdfQQX9yjulTSsQzmbRG1O/gvwHRIxfb8duD6UBnMi0FGRTTkzyuQTndNr6P
XUITPPdTnamXn1nAp/kr
=QB8C
-----END PGP SIGNATURE-----

--=-jIG6ReGmICyr8JtIFsUq--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
