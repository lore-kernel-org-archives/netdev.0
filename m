From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: fix internal switch initialization
Date: Mon, 16 Sep 2013 21:31:24 -0400 (EDT)
Message-ID: <20130916.213124.1147335768452041793.davem@davemloft.net>
References: <1379197367-19116-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de, stable@vger.kernel.org
To: zajec5@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1379197367-19116-1-git-send-email-zajec5@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Sun, 15 Sep 2013 00:22:47 +0200

> Some devices (BCM4749, BCM5357, BCM53572) have internal switch that
> requires initialization. We already have code for this, but because
> of the typo in code it was never working. This resulted in network no=
t
> working for some routers and possibility of soft-bricking them.
>=20
> Use correct bit for switch initialization and fix typo in the define.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied.
