From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] TIPC updates for upcoming v3.4
Date: Tue, 07 Feb 2012 12:33:36 -0500 (EST)
Message-ID: <20120207.123336.1274282916319329519.davem@davemloft.net>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338Ab2BGRdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 12:33:39 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon,  6 Feb 2012 19:52:33 -0500

> No real trend or correlation from one patch to the next here,
> just continued chiseling away at what were deemed to be the
> worthwhile bits that were squirreled away on sourceforge.
> I think there is on the order of 50 left after this.
> 
> I haven't forgot about your earlier request to see some of
> the tipc_printbuf related stuff go away (at least I think that
> was what you wanted to see replaced).  I'm not entirely 100%
> sure how to proceed there just yet, so I may tackle a few
> more from the remaining 50 in the interim while the log.c
> cleanup gets more thought.
> 
> Runtime tested from 64 to 32 bit x86 machines; I had to revert
> an skge commit to get my 32 bit machine functional, but that
> is largely of no interest here.

Pulled, thanks Paul.
