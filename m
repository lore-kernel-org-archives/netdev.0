From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V7 8/8] i40e/ethtool: support coalesce setting by queue
Date: Fri, 19 Feb 2016 13:56:50 -0800
Message-ID: <1455919010.3016.40.camel@intel.com>
References: <1455891846-12271-1-git-send-email-kan.liang@intel.com>
	 <1455891846-12271-9-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IOkeFhG05oNC/oJVX+Fk"
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, mitch.a.williams@intel.com,
	ogerlitz@mellanox.com, edumazet@google.com, jiri@mellanox.com,
	sfeldma@gmail.com, gospo@cumulusnetworks.com,
	sasha.levin@oracle.com, dsahern@gmail.com, tj@kernel.org,
	cascardo@redhat.com, corbet@lwn.net, decot@googlers.com
To: Kan Liang <kan.liang@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bwh@kernel.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:38395 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030467AbcBSV4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 16:56:52 -0500
In-Reply-To: <1455891846-12271-9-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IOkeFhG05oNC/oJVX+Fk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-19 at 09:24 -0500, Kan Liang wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> This patch implements set_per_queue_coalesce for i40e driver.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 +++++++
> =C2=A01 file changed, 7 insertions(+)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
--=-IOkeFhG05oNC/oJVX+Fk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWx4+iAAoJEOVv75VaS+3OPtYP/3qUsfZkAyfTwtNDYR3GlMBz
RMW4+1Q0WOTIuNjHhmIdNu4wsUKvNXDAxDgow//8iD6rN1xmY6CNPZdN9WX7mjO3
HrWhBxvS02AKAAH39U+hoxrOw0+6GXNe0BMQz4LfpMEkx8zI0vAOA5DsvZFxmG5x
5+GWzg4P+TdKEHfz5mzNf5dr8dvnJL06ibKdSRXs5SiKqEM71oT7uVkIehfVjRXR
nemFuhvSCsWyIoSQqaK1d+Fz398qw9AL40dmDTZmM5w7rJ8Ycjos+WzSq8JDIzeN
J3B6lPsYP4SXS/pOG7h/L1irFWs5eYg9PfslHc4Ltq5hpHKEQUaR6TxxlHy4XGqw
MT9AKtpnkhfzyeiEJkIqilmzpyP8K7tfJSuJyFzKgSHPfUFeChCr2JJ5/yk/3m8I
pwQXyYzyvNDdzBW4y2+RSRTkTNlYkmcDJIJ6rOwvEEaK6BlY59jmZnyCx9cqgxhN
uRhAY8XE/M7J6NbXZh9NUe7VHzgRTiZNdDD7RFdwQcEMGSLAu1wZX0+CmDpiwDNT
8EhDiVR+IR33yGexucY5L9+2RBTJZhQHWrqB/nZP+OZQkEu4j+wr3vCGmQ1zwFMN
GFbwMyqwHtG3M0C2ktaq5oEkkEoZC8JssdQuxkpDKNskH1a9gtOYwoZUjL1yVGGj
fn0e21A4dsYE681o1bFm
=1PMK
-----END PGP SIGNATURE-----

--=-IOkeFhG05oNC/oJVX+Fk--
