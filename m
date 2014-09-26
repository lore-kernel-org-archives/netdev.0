From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mellanox: Change en_print to return void
Date: Fri, 26 Sep 2014 15:17:35 -0400 (EDT)
Message-ID: <20140926.151735.307981742214921761.davem@davemloft.net>
References: <1411407622.2952.49.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411407622.2952.49.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 22 Sep 2014 10:40:22 -0700

> No caller or macro uses the return value so make it void.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> This change is associated to a desire to eventually
> change printk to return void.

Applied, thanks.
