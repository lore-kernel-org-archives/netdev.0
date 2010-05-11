From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 v2] ks8851: Low level functions for read/write to
 companion eeprom
Date: Mon, 10 May 2010 22:59:48 -0700 (PDT)
Message-ID: <20100510.225948.172605411.davem@davemloft.net>
References: <1273085155-1260-3-git-send-email-s-jan@ti.com>
	<20100506.002012.27799102.davem@davemloft.net>
	<20100511012353.GJ2589@trinity.fluff.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s-jan@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	x0066660@ti.com, Tristram.Ha@micrel.com
To: ben-linux@fluff.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20100511012353.GJ2589@trinity.fluff.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Dooks <ben-linux@fluff.org>
Date: Tue, 11 May 2010 02:23:54 +0100

> On Thu, May 06, 2010 at 12:20:12AM -0700, David Miller wrote:
>> From: Sebastien Jan <s-jan@ti.com>
>> Date: Wed,  5 May 2010 20:45:53 +0200
>> 
>> > Low-level functions provide 16bits words read and write capability
>> > to ks8851 companion eeprom.
>> > 
>> > Signed-off-by: Sebastien Jan <s-jan@ti.com>
>> 
>> Applied.
> 
> So I take it the patches that used the drivers/misc/eeprom/eeprom_93cx6.c
> are not going to be merged?

What makes you think that?  Feel free to submit such a patch and find
out for real.

If you want things done differently from the start, review patches
faster :-)
