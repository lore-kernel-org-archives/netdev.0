From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2016-05-14
Date: Sat, 14 May 2016 14:22:01 +0300
Message-ID: <20160514112201.GA3954@t440s>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33001 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbcENLWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 07:22:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are two more Bluetooth patches for the 4.7 kernel which we wanted
to get into net-next before the merge window opens. Please let me know
if there are any issues pulling. Thanks.

Johan

---
The following changes since commit ed7cbbce544856b20e5811de373cf92e92499771:

  udp: Resolve NULL pointer dereference over flow-based vxlan device (2016-05-13 01:56:14 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 72f9f8b58bc743e6b6abdc68f60db98486c3ffcf:

  Bluetooth: Add USB ID 13D3:3487 to ath3k (2016-05-13 16:54:59 +0200)

----------------------------------------------------------------
Jiri Slaby (1):
      Bluetooth: fix power_on vs close race

Lauro Costa (1):
      Bluetooth: Add USB ID 13D3:3487 to ath3k

 drivers/bluetooth/ath3k.c | 2 ++
 drivers/bluetooth/btusb.c | 1 +
 net/bluetooth/hci_core.c  | 4 ++--
 3 files changed, 5 insertions(+), 2 deletions(-)


--wac7ysb48OaltWcw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXNwpZAAoJECQj9vv5qNQSw0MQALtrBXVsNCTbRuHSzTNuEeNG
50MC3idq9STg0MbuIgd16yjjSyJtb0GFBIrcGWJBjEX4nK+vtfoq/FFXV2gArunj
5v7J+Lw5P+s7rLOrfdCh6gxfZBBFAexmdRhi1E6pzYIDty5ZOVLc8r+lvvYjRIDE
EaBusokEinsD1rJH+jRN5Zx0I0mH2CbRGRqDcS/y61eFVPA4B9dRl3BtxiOvmeNl
Kw4w9Wgz6Bhp7ll+GirPGKLHljcxlhhy6NrzQXARllaoALCFhpWdCKNzXiTL9Nyo
271v6gCCs8+tMdiBeZpsT9tlQ7s2+e+JXhYvuHG5bAWnChirYx8KjezwjEC+QjMY
nCIS17sRKpldwlgJT8KrwNkdU6PRQK7Om4cIPDEexP1hRMbz5D0pppv920IzAakv
2qY2GrnJEHuMd+NnKBrLbMPOysRYzTkbyjMNLlBhTKuTxeNxuO3OmdEchE71iT8u
pkRqGmgjX+RVJlpEJFf4FPMEZxH39DcfVuAKdGU5/gAoDbuGgjCi0b6SSiyCVfof
2BXR6C4Y1YeuFAMPW5+5xRED8aaLJ8zw7EWSwPqZgAHKNSSTGeH1sxouklY1efj/
tS2RGKhfmbqTyQtHqiJd/cUMiNw2w3gECIYcmTBxB23KqpvSa/DOpygB11VxtUne
9u4w/3lxXVqgxRtz3VOi
=NqlX
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--
