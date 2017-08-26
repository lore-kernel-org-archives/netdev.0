From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sxgbe: check memory allocation failure
Date: Fri, 25 Aug 2017 20:07:25 -0700 (PDT)
Message-ID: <20170825.200725.549810070391118977.davem@davemloft.net>
References: <20170825053551.31672-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825053551.31672-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Fri, 25 Aug 2017 07:35:51 +0200

> Check memory allocation failure and return -ENOMEM in such a case, as
> already done few lines below for another memory allocation.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied, thank you.
