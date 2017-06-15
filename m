From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: s2io: remove useless variable in fill_rx_buffers
Date: Thu, 15 Jun 2017 14:15:29 -0400 (EDT)
Message-ID: <20170615.141529.76764283182778200.davem@davemloft.net>
References: <20170615025817.GA11511@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615025817.GA11511@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Wed, 14 Jun 2017 21:58:17 -0500

> Remove useless variable rxd_index and code related.
> 
> Addresses-Coverity-ID: 1397691
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied, thanks.
