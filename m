From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 5 Jan 2005 13:25:37 -0600
Message-ID: <200501051325.40616.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <16860.5674.612383.986202@robur.slu.se> <200501051135.03493.jeremy.guthrie@berbee.com>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1848405.zG5ppPKG5L";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200501051135.03493.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1848405.zG5ppPKG5L
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

After smp_affinity adjustments and turning off IRQ balancing.

eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
          inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:537271635 errors:2377048 dropped:2377048 overruns:1849=
169=20
frame:0
          TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1804727106 (1721.1 Mb)  TX bytes:398 (398.0 b)
          Base address:0x22a0 Memory:eff80000-effa0000


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1848405.zG5ppPKG5L
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3D80qtjaBHGZBeURAjNkAJ9CabJ3ZnVy6UfHF2bkQ+XyJUP/ugCgmZhw
jZ4s0v7Q+e7diEU0AjwVY/8=
=Df1l
-----END PGP SIGNATURE-----

--nextPart1848405.zG5ppPKG5L--
