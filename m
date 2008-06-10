From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] isdn divas: fix proc creation
Date: Tue, 10 Jun 2008 12:49:43 -0700 (PDT)
Message-ID: <20080610.124943.262823260.davem@davemloft.net>
References: <200806092332.m59NW0wf014559@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adobriyan@gmail.com, kkeil@suse.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751314AbYFJTtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:49:43 -0400
In-Reply-To: <200806092332.m59NW0wf014559@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 09 Jun 2008 16:32:00 -0700

> 1. creating proc entry and not saving pointer to PDE and checking it
>    is not going to work.
> 2. if proc entry wasn't created, no reason to remove it on error path.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6, thanks.
