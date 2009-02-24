From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Doc: Refer to ip-sysctl.txt for strict vs. loose
 rp_filter mode
Date: Tue, 24 Feb 2009 03:48:29 -0800 (PST)
Message-ID: <20090224.034829.196093688.davem@davemloft.net>
References: <1235142193.2351.41.camel@localhost.localdomain>
	<20090222.000656.74298101.davem@davemloft.net>
	<1235400043.2351.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754564AbZBXLss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 06:48:48 -0500
In-Reply-To: <1235400043.2351.52.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Mon, 23 Feb 2009 15:40:43 +0100

> 
> The IP_ADVANCED_ROUTER Kconfig describes the rp_filter
> proc option.  Recent changes added a loose mode.
> Instead of documenting this change too places, refer to
> the document describing it:
>  Documentation/networking/ip-sysctl.txt
> 
> I'm considering moving the rp_filter description away
> from the Kconfig file into ip-sysctl.txt.
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Also applied, thanks a lot Jesper.
