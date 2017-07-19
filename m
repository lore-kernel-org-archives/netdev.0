From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: mediatek: remove useless code in
 mtk_poll_tx()
Date: Wed, 19 Jul 2017 16:35:10 -0700 (PDT)
Message-ID: <20170719.163510.2004236700573373540.davem@davemloft.net>
References: <20170718204805.GA30888@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: gustavo@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718204805.GA30888@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Tue, 18 Jul 2017 15:48:06 -0500

> Remove useless local variable _condition_ and the code related.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Applied.
