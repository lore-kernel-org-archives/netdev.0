From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] bgmac: Clean warning messages
Date: Sun, 08 Mar 2015 22:56:25 -0400 (EDT)
Message-ID: <20150308.225625.1598769425989443440.davem@davemloft.net>
References: <1425726626-31785-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hauke@hauke-m.de, w-lkml@lebenslange-mailadresse.de,
	zajec5@gmail.com, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425726626-31785-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Sat,  7 Mar 2015 12:10:26 +0100

> On my test environment the throughput of a file transfer drops
> from 4.4MBps to 116KBps due the number of repeated warning
> messages. This patch removes the warning messages as DMA works
> correctly with addresses using 0xC0000000 bits.
>=20
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
> ---
> Changes from V1:
>    - Updated commit message. Thanks Rafa=A9=A9 Mi=A9=A9ecki <zajec5@g=
mail.com>

Applied, thanks.
