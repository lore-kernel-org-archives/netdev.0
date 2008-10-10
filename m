From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Thu, 09 Oct 2008 22:05:13 -0700 (PDT)
Message-ID: <20081009.220513.181546765.davem@davemloft.net>
References: <20081009.211552.20994950.davem@davemloft.net>
	<20081009212755.94fe11f6.akpm@linux-foundation.org>
	<20081009.215452.193703022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751895AbYJJFFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 01:05:37 -0400
In-Reply-To: <20081009.215452.193703022.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 09 Oct 2008 21:54:52 -0700 (PDT)

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 9 Oct 2008 21:27:55 -0700
> 
> > We have a driver which has never been compileable on i386 which has
> > slipped through at least three sets of fingers only to land on the
> > usual guy's head.
> 
> The person who submitted the driver compiled it on his box,
> I made sure to hit sparc64 to try and hit the whacky cases,
> and I'm only doing these driver merges because Jeff Garzik
> is out of town so give me a break :-)))

Anyways, in case it isn't clear I'll get this fixed since it's
coming from my tree.

