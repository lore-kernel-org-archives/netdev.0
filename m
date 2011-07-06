From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: sh_eth: fix the parameter for the ETHER of
 SH7757
Date: Tue, 05 Jul 2011 23:43:02 -0700 (PDT)
Message-ID: <20110705.234302.2191506063329521897.davem@davemloft.net>
References: <4E1401D5.60506@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4E1401D5.60506@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Wed, 06 Jul 2011 15:33:57 +0900

> If the driver didn't set this parameter on the ETHER, the CPU will
> encounter the "data address error" exception.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
