From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: sh_eth: fix cannot work half-duplex mode
Date: Tue, 05 Jul 2011 23:42:55 -0700 (PDT)
Message-ID: <20110705.234255.878921838613449258.davem@davemloft.net>
References: <4E1401CF.4080804@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4E1401CF.4080804@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Wed, 06 Jul 2011 15:33:51 +0900

> When link was down, the bit of DM in ECMR was always set.
> So, we could not use half-duplex mode on the controller.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
