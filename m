From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RESEND] drivers/net/ethernet: dev_alloc_skb to
 netdev_alloc_skb
Date: Mon, 23 Jan 2012 13:53:50 -0500 (EST)
Message-ID: <20120123.135350.756110788533975068.davem@davemloft.net>
References: <1327343283-4830-1-git-send-email-netdev@pradeepdalvi.com>
	<1327344034.6317.3.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@pradeepdalvi.com, netdev@vger.kernel.org, hch@lst.de,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327344034.6317.3.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 23 Jan 2012 10:40:34 -0800

> Perhaps you should break this large patch
> into multiple separate patches.

Agreed, this patch is way too large especially for what is obviously
turning out to be a very non-trivial transformation in some cases
and also new patch submitters should generally avoid large patches
like this.
