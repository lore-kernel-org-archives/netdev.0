From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: mark expected switch fall-throughs in
 nicvf_main()
Date: Mon, 09 Oct 2017 10:43:20 -0700 (PDT)
Message-ID: <20171009.104320.709683794054164260.davem@davemloft.net>
References: <20171009164453.GA4889@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: gustavo@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171009164453.GA4889@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Mon, 9 Oct 2017 11:44:53 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Cc: Sunil Goutham <sgoutham@cavium.com>
> Cc: Robert Richter <rric@kernel.org>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Applied.
