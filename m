From: David Miller <davem@davemloft.net>
Subject: Re: Problem with "tcp: bind() fix when many ports are bound" commit
Date: Wed, 28 Apr 2010 10:51:54 -0700 (PDT)
Message-ID: <20100428.105154.267381426.davem@davemloft.net>
References: <20100428.095032.32709294.davem@davemloft.net>
	<1272476040.2267.87.camel@edumazet-laptop>
	<1272476697.2267.95.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grzegorz.chwesewicz@retis.net.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, zbr@ioremap.net
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272476697.2267.95.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Apr 2010 19:44:57 +0200

> David, I think we should revert patches for linux-2.6, and work on this
> problem more closely on net-next-2.6

Yep, I agree, I'll send the revert to Linus.

Thanks.
