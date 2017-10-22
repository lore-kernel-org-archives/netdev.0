From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tipc: mark expected switch fall-throughs
Date: Sun, 22 Oct 2017 03:07:29 +0100 (WEST)
Message-ID: <20171022.030729.1569398763946158719.davem@davemloft.net>
References: <20171020170126.GA16177@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
        netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020170126.GA16177@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Fri, 20 Oct 2017 12:01:26 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

This doesn't apply to net-next.
