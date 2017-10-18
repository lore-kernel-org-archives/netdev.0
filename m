From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipx: mark expected switch fall-through
Date: Wed, 18 Oct 2017 14:14:07 +0100 (WEST)
Message-ID: <20171018.141407.220466660962114393.davem@davemloft.net>
References: <20171016215316.GA12885@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016215316.GA12885@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Mon, 16 Oct 2017 16:53:16 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
