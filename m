From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Sun, 15 Jan 2006 01:43:15 +0100
Message-ID: <20060115004315.GW29663@stusta.de>
References: <20060105181826.GD12313@stusta.de> <43BD6C03.2080605@pobox.com> <20060105210444.GA5878@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, saw@saw.sw.com.sg,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751549AbWAOAnR@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20060105210444.GA5878@xi.wantstofly.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 05, 2006 at 10:04:44PM +0100, Lennert Buytenhek wrote:
> On Thu, Jan 05, 2006 at 01:57:07PM -0500, Jeff Garzik wrote:
> 
> > >This patch removes the obsolete drivers/net/eepro100.c driver.
> > >
> > >Is there any known problem in e100 still preventing us from removing 
> > >this driver (it seems noone was able anymore to verify the ARM problem)?
> > 
> > Still waiting to see if e100 in -mm works on ARM.
> 
> e100 seems to work okay on the (modern) ARM CPUs I've tried.  The case
> where e100 failed but eepro100 worked was (I think) on older ARM hardware,
> and I'm not sure whether that kind of hardware is used anymore..

Jeff, is this enough to accept my patch?

> cheers,
> Lennert

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
