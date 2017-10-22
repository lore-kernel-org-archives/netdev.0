From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rose: mark expected switch fall-throughs
Date: Sun, 22 Oct 2017 02:02:59 +0100 (WEST)
Message-ID: <20171022.020259.1780127118966469792.davem@davemloft.net>
References: <20171019180351.GA11525@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019180351.GA11525@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 19 Oct 2017 13:03:51 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
