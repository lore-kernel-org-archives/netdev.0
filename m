From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V4 3/8] net/ethtool: introduce a new ioctl for per queue
 setting
Date: Sun, 14 Feb 2016 18:33:02 +0000
Message-ID: <1455474782.2801.133.camel@decadent.org.uk>
References: <1454917540-10648-1-git-send-email-kan.liang@intel.com>
	 <1454917540-10648-4-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-c4AHe4oF1MgwXIZnxdT9"
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com
To: Kan Liang <kan.liang@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57996 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751074AbcBNSdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 13:33:20 -0500
In-Reply-To: <1454917540-10648-4-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-c4AHe4oF1MgwXIZnxdT9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-08 at 02:45 -0500, Kan Liang wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> Introduce a new ioctl ETHTOOL_PERQUEUE for per queue parameters setting.
> The following patches will enable some SUB_COMMANDs for per queue
> setting.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
[...]

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-c4AHe4oF1MgwXIZnxdT9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsDIXue/yOyVhhEJAQpRJg//WcOMlAxz8hZ6YgjqEc217tF/9WpPrWhZ
e8v0z1rnJebsSJ253k+WUgz1WxhDA8ooOUXXQ6dnVNlCv9mxXokgbexuDrEZ/ipM
2AzKv7z1F7RVRo6smo6HcHRKjBZukWHJVYcX+F2tRNGYtbwLlUbPKcmIt3LoG/H6
kEnXw6ErfGw7W1/A01DQ1rated6o2qaCeBH8W86WTLondj24I5257I5VdQ8mBiHD
JOuhWYD/EpqqQbRw0eW2OfAre6MPAYOf9ZjrTOkSEgJjmFeef8CORMd9igMF3vMW
GbahKAH0x/laeypMTiXKqKGn5ZigbQzcllSODj9PwPqd62mNh7K9yWhQ47f5PFel
8GgEjBGTLT/+YDf7pqJKgl2Z0C8cC+yU45z67Fmj8kKXcbtdpMTOH5BKhoQXCA+P
b1jxhArCk8HOSOgZ0ysJR6AT2+2PmeXQpxDL5Fx0u5nVblTeYNwO7yEhFZLyqUnP
hfmKmHArO0jz4SkI0um2qwCifqW1503j+zhwWtwk26Zy0xTYKjkf2ghNq9A/Ebh6
q8NzQB7kPLxBRVsAkeAhLS6S6FvbSUeuUSYxHOLf9I81Ty5iKS2SgkbP1Cc4T7wY
YMCmSqP3iE0ma33VQl1ij3bsBxmuh2yTRca+JQRpCEJrExS5Vni3W2hNcqojAh9i
7EZpfcGazVw=
=pA7x
-----END PGP SIGNATURE-----

--=-c4AHe4oF1MgwXIZnxdT9--
