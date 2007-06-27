From: David Miller <davem@davemloft.net>
Subject: Re: [NET 01/05]: dev_mcast: unexport dev_mc_upload
Date: Wed, 27 Jun 2007 01:25:32 -0700 (PDT)
Message-ID: <20070627.012532.94889634.davem@davemloft.net>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
	<20070622122332.15215.1295.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752343AbXF0IZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 04:25:13 -0400
In-Reply-To: <20070622122332.15215.1295.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 22 Jun 2007 14:24:07 +0200 (MEST)

> [NET]: dev_mcast: unexport dev_mc_upload
> 
> dev_mc_add/dev_mc_delete take care of uploading the list when
> necessary and thats the only interface other code should use.
> Also remove two incorrect calls in DECnet.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.23, thanks Patrick.
