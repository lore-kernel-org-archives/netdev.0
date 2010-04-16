From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 15:57:07 -0700 (PDT)
Message-ID: <20100416.155707.66748057.davem@davemloft.net>
References: <1271446679.16881.4298.camel@edumazet-laptop>
	<20100416.154932.147279343.davem@davemloft.net>
	<20100416.155340.256882855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37381
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932669Ab0DPW5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 18:57:02 -0400
In-Reply-To: <20100416.155340.256882855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 16 Apr 2010 15:53:40 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Fri, 16 Apr 2010 15:49:32 -0700 (PDT)
> 
>> Great, I'll add this to net-next-2.6 right now.
> 
> I had to add an include of linux/vmalloc.h to net/core/sysctl_net_core.c
> to fix the build while committing this.

net/core/net-sysfs.c needed it too :-/
