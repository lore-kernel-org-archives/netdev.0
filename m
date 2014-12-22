From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] net: s6gmac: remove driver
Date: Mon, 22 Dec 2014 16:29:23 -0500 (EST)
Message-ID: <20141222.162923.1183357932658326852.davem@davemloft.net>
References: <20141111.113007.194586174190893576.davem@davemloft.net>
	<1419190059-16501-1-git-send-email-dg@emlix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dg@emlix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419190059-16501-1-git-send-email-dg@emlix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Daniel Gl=F6ckner <dg@emlix.com>
Date: Sun, 21 Dec 2014 20:27:39 +0100

> The s6000 Xtensa support has been removed from the kernel in
> 4006e565e1500db4. There are no other chips using this driver.
>=20
> While the Mentor/Alcatel PE-MCXMAC IP core is also used in other
> designs (Freescale Gianfar/UCC, QLogic NetXen, Solarflare, Agere
> ET-1310, Netlogic XLR/XLS), none of these use this driver as it
> heavily depends on the s6000 DMA engine. In fact, there is no
> code sharing across any of the aforementioned devices.
>=20
> Signed-off-by: Daniel Gl=F6ckner <dg@emlix.com>

Applied, thanks.
