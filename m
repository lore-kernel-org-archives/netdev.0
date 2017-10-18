From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: af_decnet: mark expected switch fall-throughs
Date: Wed, 18 Oct 2017 13:58:01 +0100 (WEST)
Message-ID: <20171018.135801.680252200033261577.davem@davemloft.net>
References: <20171016201122.GA29615@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016201122.GA29615@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Mon, 16 Oct 2017 15:11:22 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
