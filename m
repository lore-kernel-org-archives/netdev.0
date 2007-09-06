From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/1] tg3: remove sparse warnings
Date: Thu, 06 Sep 2007 12:42:56 -0700 (PDT)
Message-ID: <20070906.124256.41638433.davem@davemloft.net>
References: <20070906190739.GA10916@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	shemminger@linux-foundation.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:35012
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755211AbXIFTnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 15:43:08 -0400
In-Reply-To: <20070906190739.GA10916@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Gospodarek <andy@greyhouse.net>
Date: Thu, 6 Sep 2007 15:07:40 -0400

> 
> Removed sparse warnings from tg3 driver.  The new logic seems fine (I
> don't immediately see where we are running over values for any of the
> variables that need to be saved).
> 
> This patch compiles fine and I'm currently using a tg3 with the patched
> driver to post this patch as a basic proof of concept.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Cc: Michael Chan <mchan@broadcom.com>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: David S. Miller <davem@davemloft.net>

I went over this with a fine toothed comb, and it looks fine.

Patch applied to net-2.6.24, thanks!

