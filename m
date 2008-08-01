From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch for 2.6.27? 2/2] drivers/net/netxen/netxen_nic_hw.c: fix
 printk warnings
Date: Fri, 1 Aug 2008 00:01:54 -0700
Message-ID: <20080801000154.46a457e2.akpm@linux-foundation.org>
References: <200807301950.m6UJoDY4013256@imap1.linux-foundation.org>
	<20080801061952.GI27241@verge.net.au>
	<20080731232809.470dd7d1.akpm@linux-foundation.org>
	<20080731.235501.201774280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47111 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753772AbYHAHCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 03:02:31 -0400
In-Reply-To: <20080731.235501.201774280.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jul 2008 23:55:01 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 31 Jul 2008 23:28:09 -0700
> 
> > I wonder who was the first 64-bit bright spark who decided to use `long'.
> 
> /me hides :)

y'know, I actually did type "bright sparc".  Now I wish I hadn't fixed it.
