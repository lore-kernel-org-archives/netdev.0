From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: sh_eth: fix incorrect RX length error if
 R8A7740
Date: Thu, 13 Jun 2013 03:02:59 -0700 (PDT)
Message-ID: <20130613.030259.1909989123383615468.davem@davemloft.net>
References: <51B91D41.1000908@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <51B91D41.1000908@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Thu, 13 Jun 2013 10:15:45 +0900

> This patch fixes an issue that the driver increments the "RX length error"
> on every buffer in sh_eth_rx() if the R8A7740.
> This patch also adds a description about the Receive Frame Status bits.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied, thanks.
