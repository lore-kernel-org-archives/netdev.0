From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Fri, 11 May 2007 14:12:25 -0700
Message-ID: <20070511141225.cf7a6909.akpm@linux-foundation.org>
References: <200705110552.l4B5qnwC007799@shell0.pdx.osdl.net>
	<4644D8AF.7060403@garzik.org>
	<20070511.140309.59656886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jarkao2@o2.pl,
	jura@netams.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:52049 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760763AbXEKVMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 17:12:39 -0400
In-Reply-To: <20070511.140309.59656886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 May 2007 14:03:09 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 11 May 2007 16:57:19 -0400
> 
> > applied
> 
> I was under the impression that this patch didn't actually fix the
> problem yet?  I might be thinking about something else...

yeah, sorry, it seems that the discussion is ongoing.  Please drop the
patch.  I did.
