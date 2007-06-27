From: David Miller <davem@davemloft.net>
Subject: Re: [NET 02/05]: dev: introduce generic net_device address lists
Date: Wed, 27 Jun 2007 01:26:30 -0700 (PDT)
Message-ID: <20070627.012630.09952050.davem@davemloft.net>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
	<20070622122333.15215.96140.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42603
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752263AbXF0I0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 04:26:11 -0400
In-Reply-To: <20070622122333.15215.96140.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 22 Jun 2007 14:24:09 +0200 (MEST)

> [NET]: dev: introduce generic net_device address lists
> 
> Introduce struct dev_addr_list and list maintenance functions
> based on dev_mc_list and the related functions. This will be
> used by follow-up patches for both multicast and secondary
> unicast addresses.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.23
