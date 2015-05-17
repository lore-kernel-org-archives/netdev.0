From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2015-05-17
Date: Sun, 17 May 2015 15:51:36 +0300
Message-ID: <20150517125136.GA763@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

A couple more Bluetooth updates for 4.1:

- New USB IDs for ath3k & btusb
- Fix for remote name resolving during device discovery

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 110bc76729d448fdbcb5cdb63b83d9fd65ce5e26:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-05-12 21:10:38 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 177d0506a911eb60b38b172215df5325ed94fa64:

  Bluetooth: Fix remote name event return directly. (2015-05-14 10:35:04 +0200)

----------------------------------------------------------------
Dmitry Tunin (1):
      Bluetooth: ath3k: add support of 04ca:300f AR3012 device

Wen-chien Jesse Sung (2):
      Bluetooth: ath3k: Add a new ID 0cf3:e006 to ath3k list
      Bluetooth: btusb: Add support for 0cf3:e007

Wesley Kuo (1):
      Bluetooth: Fix remote name event return directly.

 drivers/bluetooth/ath3k.c | 4 ++++
 drivers/bluetooth/btusb.c | 3 +++
 net/bluetooth/hci_core.c  | 6 ++++--
 3 files changed, 11 insertions(+), 2 deletions(-)


--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVWI7YAAoJECQj9vv5qNQSy48P/i/xjBW4S11WwJLXj6PNQ2QQ
vLvBGMWTtfuXhGlMChli2v6BysUt35N9+0UwfCKFt/UD9ZKiUyNvC9tCmpl7g2Hb
btIZasmZ2cjukGe4H3OL35Wi/RnfwjfAlVew0WQKYOPPACdrqy3P32/2J57dc7HA
oJRCDkvnnZ3a5k03tkBLtEBVF+iusg5t8ftiD3m48PV4+wdNPpLRp1899Wln9Og9
sT6Nd/bqhYLLI//Z8Jib8RSOKS/i4aVpDGFQWOpURtDeOuGKjl7M9IBcRsRo8iZT
Fme/hGzZovAhyh0HB7mnVqZT8DR7UzfeZInMTxXr68Sgv7LuCqVBPAtTIe0M5Y9v
3EY95AqS/8pDXtuN201IwMOX97pZpkOp2Ob69LqxtLg/0EnHYhdbD/HA4mT48DSe
DvwRNyj/n1450d8YHYoCG4ajFpcOzxX3UFqaJXNKBJfcqeK6VwTcQ+lITkCu/dqB
rPcNPUbem5vP2vwfrYBWwSrD5vHYnPfn4UinrxpyKyaIUgDlL9a1+fNUp/B5mdzp
L2h4TiMRQoJv7D9OXuNBIojRaYNecCLzRJtZXKKEmUDRzKWhx3SnaCxu17GtnqbW
PwbP6wVASV/HT2ctHSw152M0tEba6Qw32QHqq9RFcwvpHkygwm9VIJkouOpibg5H
jMAwRpuGhZOB6K9g4kru
=MmM5
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
