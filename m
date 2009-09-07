From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix hydra printk format warning
Date: Mon, 07 Sep 2009 01:57:42 -0700 (PDT)
Message-ID: <20090907.015742.83956406.davem@davemloft.net>
References: <20090904172037.b2dd7f20.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org,
	geert@linux-m68k.org, zippel@linux-m68k.org
To: randy.dunlap@oracle.com
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20090904172037.b2dd7f20.randy.dunlap@oracle.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 4 Sep 2009 17:20:37 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> m68k:
> drivers/net/hydra.c:178: warning: format '%08lx' expects type 'long unsigned int', but argument 3 has type 'resource_size_t'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied to net-next-2.6, thanks.
