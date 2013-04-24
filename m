From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 08/14] pci: Add SRIOV helper function to determine if
 VFs are assigned to guest
Date: Wed, 24 Apr 2013 14:40:36 -0700
Message-ID: <1366839636.2871.7.camel@jtkirshe-mobl>
References: <5175B0A9.7070100@intel.com> <20130423125101.00005bb7@unknown>
	 <CAErSpo58vRW+QoHMTzo4vNi4n8Z2RhG43rBesTUJS-4HRwfd1w@mail.gmail.com>
	 <20130424.161825.1007847105309092978.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gRC6EHne2fs6BlVQCyfv"
Cc: bhelgaas@google.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20130424.161825.1007847105309092978.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-gRC6EHne2fs6BlVQCyfv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-04-24 at 16:18 -0400, David Miller wrote:
> From: Bjorn Helgaas <bhelgaas@google.com>
> Date: Wed, 24 Apr 2013 14:10:38 -0600
>=20
> > But this is no worse in either respect than the code it replaces, and
> > it's certainly better to have it all in one place, so:
> >=20
> > Acked-by: Bjorn Helgaas <bhelgaas@google.com>
> >=20
> > If you have a chance, you could remove the "extern" from the
> > declaration in include/linux/pci.h.  There's a mix there right now,
> > and I have a patch in the queue that removes them all.
>=20
> Jeff please respin your pull request with Bjorn's ACK as well as
> the "extern" removal he's asking for.
>=20
> Thanks.

Working on it, I will have a updated patch (and series) submitted later
tonight.

--=-gRC6EHne2fs6BlVQCyfv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJReFFUAAoJEOVv75VaS+3OFksP/1ozYm21/iukoXZg6B3RMsGk
1DyQRUl9TWrJFGuCATE17E3784HRbeurm6Y3iRdKz3jeBRRCz6VAHUDlemKb2oPJ
WUHBSQRocHFXs9VxSaTwcEV7qI+Rf6P4B1N9H+PCVKY3Vfn9HkzpiS4q3bz6oqi8
rOmRlkrjqZ4MJwOKjePRcyy+UYb4stJgYkUbI/hGdFBWBeFevGUf+qK/W2w4SWJw
BFCufMQujr8YUG/zYZTOK0FU81329WLFRfNupt630YpzQJzyEVQisyMLbhjfe6wD
4WWrFlDHtRoILCBRkDcO7WgktUUdIYxBjl5aLJvHIWoyM3x6Ktics+TunL7hi7qd
79ZeGnEG0Q7bbu8aWdZ7UOO0ACLhbCyIzGWF3B8owxV0MVVlA222YOpdSMSKG4cY
3QwzV5JQ32GysOPLhhg3Z5MA+xIMaBZ0hwH3ycdIoodsA4JY6ilPaGnEzz3d9Xvk
LY0+XSDTQPrWx211oQieh1dYCfMPcpSVcBtgTVj4EpXi1buZQhCLCwtzloklJR2n
hK08PBjiOy4KcJTAuHJmgIundiTQ04FIEGgRxv4xvEYaO4olZxqDOkfKFa2enZdL
OtyDs7z73cSmXfX9iNdrJm7kdRzNeK6LyDtHFPf273YG1ZZbleZ+eA5XNqWtDdlA
8VWFnZHwvNDKOnG8+8+D
=uUBG
-----END PGP SIGNATURE-----

--=-gRC6EHne2fs6BlVQCyfv--
