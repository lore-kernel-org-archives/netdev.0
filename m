From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen - define and use pktgen_dbg,err,warn,info
Date: Tue, 31 Jul 2007 18:28:56 -0700 (PDT)
Message-ID: <20070731.182856.74751972.davem@davemloft.net>
References: <1184800861.5863.54.camel@localhost>
	<20070730.160540.48528135.davem@davemloft.net>
	<1185925686.14777.22.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35931
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754917AbXHAB2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 21:28:55 -0400
In-Reply-To: <1185925686.14777.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 31 Jul 2007 16:48:06 -0700

> I'd like to see macros added to kernel.h for:
> 
> 	pr_err
> 	pr_notice
> 	pr_warn
> 	pr_alert
> 	pr_crit
> 	pr_emerge

No objections here :)
