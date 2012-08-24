From: David Miller <davem@davemloft.net>
Subject: Re: [linuxppc-release] [PATCH] net/fsl_pq_mdio: add support for
 the Fman 1G MDIO controller
Date: Fri, 24 Aug 2012 16:25:41 -0400 (EDT)
Message-ID: <20120824.162541.256137760046203132.davem@davemloft.net>
References: <1345757047-14657-1-git-send-email-timur@freescale.com>
	<5037E301.2080805@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932668Ab2HXUZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 16:25:45 -0400
In-Reply-To: <5037E301.2080805@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Fri, 24 Aug 2012 15:24:33 -0500

> Timur Tabi wrote:
>> The MDIO controller on the Frame Manager (Fman) is compatible with the
>> QE and Gianfar MDIO controllers, but we don't care about the TBI because
>> the Ethernet drivers (FMD) take care of programming it.
>> 
>> Signed-off-by: Timur Tabi <timur@freescale.com>
> 
> This patch isn't quite right.  I'll post a new version soon.

I already applied it to net-next, didn't you see?
