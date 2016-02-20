From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2016-02-20
Date: Sat, 20 Feb 2016 20:16:25 +0200
Message-ID: <20160220181625.GA1231@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tKW2IUtsqtDRztdT"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's an important patch for 4.5 which fixes potential invalid pointer
access when processing completed Bluetooth HCI commands.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit d07c0278da1f4cfc91c3d46d0d07a0d13a949892:

  net: bcmgenet: Fix internal PHY link state (2016-02-19 23:51:40 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 3bd7594e69bd97c962faa6a5ae15dd8c6c082636:

  Bluetooth: hci_core: Avoid mixing up req_complete and req_complete_skb (2016-02-20 08:52:28 +0100)

----------------------------------------------------------------
Douglas Anderson (1):
      Bluetooth: hci_core: Avoid mixing up req_complete and req_complete_skb

 net/bluetooth/hci_core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--tKW2IUtsqtDRztdT
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWyK15AAoJECQj9vv5qNQSCyoP/iz263tzD+pQq0pyRXp2xXeZ
DEGSG3Vvsyykv2L85qsYTN0sZkSW9tE3Vuy9xCER+s4YE8KqGNCk/wE6INzEGHMw
PMtKTtSGJAZHKnkz2DNpNxwJeFTSnOA0TUpGSHpI5qzbegJYRSk5d/bL+AdgfnuP
yrHMe07WQF6Owj82YgIKfJ02PH86x2BuldYl1u1l/8UY1bMfqRGiyXa7yEgjmvO7
0p9fCO80mQsQ5rYJqlix+tQNze85qjvot9q8VcVFa11PeRotZ0sMFBuqZgI4M+Eu
HhhlM4yrE0Rq51F9bDvyrlptnCfWcQ3nPbxSItBAuuk259hjtDXn14GRVGXq0cG+
oHGcZcbww6tNr7J348cNzq5HsvV3KTK3Z8BlZdrlykJKZEtO5Zb5PyytW1ch8IAD
0EjuxTWisR4TYAXcYgpkOcXUrieRpyQWOk5bTDxUpc5Ls9mcOHuMxoMl1gSd94wv
fBoe30aKU8SrRIwLzrAV+v3w4vcz2AgAlaWRq/JUASV2dB1r0QpAlMKf1RDJ17RX
oBzlh/Wv3qqsyOcYt+oOy1w+hKpYIwdo9vfdBiaM3Q9/P0xlBMK0aVKDLEASh6D7
LFfAmSAig08CnjKb0GKRYgmMS2EyLRzfw/A0ogWqDeH5fH9q47QqxRyDuep3oBUu
O20Zldui/4QHNwEKU5B3
=xYJ7
-----END PGP SIGNATURE-----

--tKW2IUtsqtDRztdT--
