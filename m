From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: clean up my printk uglyness
Date: Thu, 01 Apr 2010 19:33:21 -0700 (PDT)
Message-ID: <20100401.193321.257691706.davem@davemloft.net>
References: <20100401145356.GB14069@shamino.rdu.redhat.com>
	<20100401173007.GC14069@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, brandon@ifup.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47961
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757471Ab0DBCdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:33:20 -0400
In-Reply-To: <20100401173007.GC14069@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 1 Apr 2010 13:30:07 -0400

> On Thu, Apr 01, 2010 at 10:53:56AM -0400, Neil Horman wrote:
>> Fix formatting on r8169 printk
>> 
>> Brandon Philips noted that I had a spacing issue in my printk for the last r8169
>> patch that made it quite ugly.  Fix that up and add the PFX macro to it as well
>> so it looks like the other r8169 printks
>> 
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> 
>> 
> Grr, yes thanks, V2, fixing my idiocy :)
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
