From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: decnet: dn_nsp_out: use swap macro in
 dn_mk_ack_header
Date: Wed, 01 Nov 2017 12:06:09 +0900 (KST)
Message-ID: <20171101.120609.268880918910495588.davem@davemloft.net>
References: <20171028203948.GA6173@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171028203948.GA6173@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Sat, 28 Oct 2017 15:39:48 -0500

> Make use of the swap macro and remove unnecessary variable tmp.
> This makes the code easier to read and maintain.
> 
> This code was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
