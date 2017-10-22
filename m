From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_unix: mark expected switch fall-through
Date: Sun, 22 Oct 2017 03:10:29 +0100 (WEST)
Message-ID: <20171022.031029.1949264575459667161.davem@davemloft.net>
References: <20171020170530.GA19922@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020170530.GA19922@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Fri, 20 Oct 2017 12:05:30 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
