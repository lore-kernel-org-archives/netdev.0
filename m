From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/6 v2][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Oct 2011 15:53:04 -0700
Message-ID: <1318891984.15830.2.camel@jtkirshe-linux>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111017.184922.373702739993889767.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-wbtFlDSAsfO8DiLb18ke"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6413 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134Ab1JQWxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 18:53:24 -0400
In-Reply-To: <20111017.184922.373702739993889767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wbtFlDSAsfO8DiLb18ke
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-10-17 at 15:49 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 17 Oct 2011 05:20:56 -0700
>=20
> > The following series contains updates to ixgbe, igbvf and igb.
> > This version of the series contains the following changes:
> >=20
> > - igb fix/add check if subordinate VFs are assigned to VM's
> > - igbvf fix for trunk VLAN
> > - ixgbe 2 fixes for ethtool and 1 endianess fix
> >=20
> > -v2 update the igb patch to resolve a variable initialization warning
> >=20
> > The following are changes since commit fd38f734cb8200529e281338514945fc=
bff2364b:
> >   igbvf: convert to ndo_fix_features
> > and are available in the git repository at
> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
>=20
> Patch #5 adding timestamp offloading for ixgbe has some legitimate
> pushback from Richard Cochran, why don't we defer that patch while that
> discussion transpires?
>=20
> I'm perfectly fine with the other patches in this series.
>=20
> Please respin the remaining 5 patches into a pull request and I'll
> take them into net-next, thanks Jeff!
>=20

Sounds good, I have that ready in an hour or so.

Thanks!

--=-wbtFlDSAsfO8DiLb18ke
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOnLHCAAoJEOVv75VaS+3OAcEP/0Z05Qs8v39H58lziG0whDUq
0ZkgBb1ZeHutlN1Vk6mMkgLOXnl1js0sbveXDHH1WxJwjdCESPJ6t2emkeaak4Y4
ku+lFPD9qP2aAsC5QK1HLaQxH3eMf0FDGaYPDia9IqizGunAx5Qa+4d+ssX6EFX/
5ebqWnrryoDvUMfSAmqMaW4e4sQ5+KwGWjoLAFo+G3VscgAngdcBDxbWikJ3Iqqd
teyBoGDmULR9HeU0Jh097Q8C01CnO4rU7ImGimzgnAS+/DcewURiW8J703318xQ9
7YW527ah/7g7HkhuN6jGmfDBtdJ8qi5So89rAalTUkJyOEJEvFWZE5GDsLIBMego
j1UOQkxd7hKZpj2TZmCjg1Yb5bMGXHG1q0svDSV8U0ETVwKGBOm/2+2HxTeYk2Uh
MIdPyo6R1mEBGMCJz5NfsMX7Co1wn6+vhW8on4mHvy5PCI+R96JFak0gntixje6J
dPcdqKEBzpPVanRavrVQp4hRHZiRlBQWAzgEBz1I8RA3nPadfJUA4bItV+Hg+af8
ptX16Mq7bHDozvyvzaRa6MJTPNHWF1NX9ZKxn60d/uPNV6xEnAhBn8GmgUKtt+37
opiIJgPTWL1f7/ZRrcOUESy+pX4khzpT077IJLGcPofbT5hA5G3R57bw4znfJg5i
cG7bUf43dKiNiMdIMhDp
=28dn
-----END PGP SIGNATURE-----

--=-wbtFlDSAsfO8DiLb18ke--
