From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: decnet: dn_nsp_in: use swap macro in
 dn_nsp_rx_packet
Date: Wed, 01 Nov 2017 12:06:04 +0900 (KST)
Message-ID: <20171101.120604.1874615413288995759.davem@davemloft.net>
References: <20171028193845.GA24795@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171028193845.GA24795@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Sat, 28 Oct 2017 14:38:45 -0500

> Make use of the swap macro and remove unnecessary variable tmp.
> This makes the code easier to read and maintain.
> 
> This code was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
