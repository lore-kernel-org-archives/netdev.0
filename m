From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V7 7/8] i40e/ethtool: support coalesce getting by queue
Date: Fri, 19 Feb 2016 13:55:34 -0800
Message-ID: <1455918934.3016.39.camel@intel.com>
References: <1455891846-12271-1-git-send-email-kan.liang@intel.com>
	 <1455891846-12271-8-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yF6PI00m9C09CFWME73g"
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
Received: from mga11.intel.com ([192.55.52.93]:12849 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030467AbcBSVzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 16:55:36 -0500
In-Reply-To: <1455891846-12271-8-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yF6PI00m9C09CFWME73g
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-19 at 09:24 -0500, Kan Liang wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> This patch implements get_per_queue_coalesce for i40e driver.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 +++++++
> =C2=A01 file changed, 7 insertions(+)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
--=-yF6PI00m9C09CFWME73g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWx49WAAoJEOVv75VaS+3OuZ4QAKP9GPm61p2E4ykext1LOOX6
AXN49A0m5ffnhdWA69ulUjktdX/MtcEVwdI3pXIqOghVQK7xlyP0POxCBR9hYFHK
SiSFpk7bmDV0UHGX0LUDtIqWo8cFsy9r6ep/WR6WPo4yh+AwSpW/4/oZ662Q8/AA
uWl+lZIqkhXuKcxWKbh7mzdnIxxcdWyKtrD3rf6A+LrAXNDEZBjAYXAMkcnbCWBQ
gZEvlWy9YY5AKrzMG1EeUEsyZBpTAdtkCPwJ9HSBcmBi03+aZwBq1KN5W3/YSFi5
PdmA7Y/URicMcuRFHSnnDVael/+6WIXfJb55KEEZt4PFrnV8Gm7jVp6Snn0MZNdK
myIcUobYeaWi5iWvzrcUREWWDORl6HdKRfTHBW3e30hY1kemDHktSUnEvJvsJbGu
0yzVu3S4OmCYjBqGYbglzYFtsWAnbao9Q+7wXYpNc47k08PazLbj2LPWkJ3lzoK9
uG3AsmLLFUA1gHtYj2XsmWwpybj6zwyGmsiM4pv0G91Z1DE6CCDl1AnDaypsR3qs
i4bacnNw4Rvh6yI0hOP8+KLQC0dEdQxS0qs2jr9YfGZSygHRomanfd16xLzTbSoe
msz9xFHOZSr5t/k7lL9db8uFOdMiDJ2q5MKrlE2VI6WhISAMj7H6foSaJfsdR1hv
dDq83IPCtk6pRAo/uQcw
=uLHn
-----END PGP SIGNATURE-----

--=-yF6PI00m9C09CFWME73g--
