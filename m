From: David Miller <davem@davemloft.net>
Subject: Re: [NET 03/05]: dev_mcast: switch to generic net_device address
 lists
Date: Wed, 27 Jun 2007 01:27:25 -0700 (PDT)
Message-ID: <20070627.012725.26531334.davem@davemloft.net>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
	<20070622122335.15215.27024.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752617AbXF0I1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 04:27:06 -0400
In-Reply-To: <20070622122335.15215.27024.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 22 Jun 2007 14:24:10 +0200 (MEST)

> [NET]: dev_mcast: switch to generic net_device address lists
> 
> Use generic net_device address lists for multicast list handling.
> Some defines are used to keep drivers working.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.

Hopefully we can convert the drivers over time and
eventually at some future point kill the macros.
