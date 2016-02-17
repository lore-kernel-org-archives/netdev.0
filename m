From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V5 4/8] net/ethtool: support get coalesce per queue
Date: Wed, 17 Feb 2016 00:57:54 +0000
Message-ID: <1455670674.1143.19.camel@decadent.org.uk>
References: <1455625964-8943-1-git-send-email-kan.liang@intel.com>
	 <1455625964-8943-5-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gfBJPOyhCUkL8rsGcL4T"
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
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46779 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933415AbcBQA6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 19:58:11 -0500
In-Reply-To: <1455625964-8943-5-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gfBJPOyhCUkL8rsGcL4T
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-16 at 07:32 -0500, Kan Liang wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> This patch implements sub command ETHTOOL_GCOALESCE for ioctl
> ETHTOOL_PERQUEUE. It introduces an interface get_per_queue_coalesce to
> get coalesce of each masked queue from device driver. Then the interrupt
> coalescing parameters will be copied back to user space one by one.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
[...]

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.
--=-gfBJPOyhCUkL8rsGcL4T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsPFkue/yOyVhhEJAQrOiA//abE+yYS5OjaUjf3ptU6Ku7jPQQ16xBT4
JEnNVyD9gFW6hpbpDPQUlVb+qoMTiA0/0Av0G+lOlOMV7VcOWMNX0abnWZjA4Ibq
nH+PCeJ1N0gY72Bj+UQnHpTwm5ZHVB84j9shHr6g6tVWXB+uPFWQyKcwZUJ7F5m3
SX02lOEiol96oB8Yvn8naKjxvTF2I6z6W+pKSz8Jv7m4LES5zGezl5k2xb1VHx0W
cCy38BSsyC5jJhovyj7sT4cwUfx06aQvcQ+ymJyFJFx0BE60trM1pppLjs14LQS+
YKvwRmhs2z6UiU4e9P4Kx4YO3ZIdv5CIFkaSjHPIvkDSYj3qr1TMO9iQ1kb2GIAC
hEs9DY8hYvRzNGkPj6ZIDKSHEpSRtIHhi5NCLXVD8Ntt/Dypcb80GZmoyYU0IjWe
+R7IMgFUmqvptDK9ic9f8Yy0IdkftFfgnWo0AMC5jvDzotOrkM1pDFo4kSNcmWpp
arKb4hb5wCsnCe4AHTnNZqdYQyzSkaXkrjl8UiCB3uiJ6w96K7+oL9FHsl9cAX/C
bq4DC/5VMueIkGrmA6GIRtVdjoOFGb28H7T0bu1ZWiKn0gyKVYgIPdH5gwvtrwb0
FXc2bCk2MXCJhfH+0u3Eugi5FdfreGUxIPNPFRugbQ4Cg+xFaFSHUXW47OFp48+x
QLQw9h2S2gs=
=SWCF
-----END PGP SIGNATURE-----

--=-gfBJPOyhCUkL8rsGcL4T--
