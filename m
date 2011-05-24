From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for May 24 (ratelimits, CONFIG_PRINTK not
 enabled)
Date: Tue, 24 May 2011 15:32:22 -0400 (EDT)
Message-ID: <20110524.153222.1953796640575918161.davem@davemloft.net>
References: <20110524140212.a4f19769.sfr@canb.auug.org.au>
	<20110524113328.e3d5867b.randy.dunlap@oracle.com>
	<1306262988.2298.49.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1306262988.2298.49.camel@Joe-Laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 24 May 2011 11:49:48 -0700

> On Tue, 2011-05-24 at 11:33 -0700, Randy Dunlap wrote:
>> Adding <linux/ratelimit.h> to <asm-generic/bug.h> causes other problems:
> 
> Yup, that's not a good solution.

Please come up with a fix or I'll have to revert, thanks Joe.
