From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Change netdev_<level> logging functions
 to return void
Date: Fri, 26 Sep 2014 15:17:44 -0400 (EDT)
Message-ID: <20140926.151744.2073645799506529842.davem@davemloft.net>
References: <1411409450.2952.55.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411409450.2952.55.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 22 Sep 2014 11:10:50 -0700

> No caller or macro uses the return value so make all
> the functions return void.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> This change is associated to a desire to eventually
> change printk to return void.

Also applied, thanks Joe.
