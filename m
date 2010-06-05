From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] syncookies: make v4/v6 synflood warning
 behaviour the same
Date: Sat, 05 Jun 2010 02:53:16 -0700 (PDT)
Message-ID: <20100605.025316.242146534.davem@davemloft.net>
References: <1275561792-24179-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46367
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932681Ab0FEJxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:53:08 -0400
In-Reply-To: <1275561792-24179-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  3 Jun 2010 12:43:12 +0200

> both syn_flood_warning functions print a message, but
> ipv4 version only prints a warning if CONFIG_SYN_COOKIES=y.
> 
> Make the v4 one behave like the v6 one.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
