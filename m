From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/9] sfc: Wait at most 10ms for the MC to
 finish reading out MAC statistics
Date: Fri, 23 Apr 2010 15:58:04 -0700 (PDT)
Message-ID: <20100423.155804.76753664.davem@davemloft.net>
References: <1272062009.5520.27.camel@achroite.uk.solarflarecom.com>
	<20100423.153633.45897185.davem@davemloft.net>
	<1272063270.5520.39.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50122
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752825Ab0DWW57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:57:59 -0400
In-Reply-To: <1272063270.5520.39.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 23 Apr 2010 23:54:30 +0100

> This makes no sense.  You want to put a quota on bug fixes?  I could
> arbitrarily pick some but I'm still going to want to get the other fixes
> into distributions.

It's not a quota.  It's a request that only the most catastropic
bugs get fixed this late in the RC.

You don't have 9 catastropic bugs to fix in your driver.
