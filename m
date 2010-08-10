From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] etherdevice.h: fix kernel-doc typo
Date: Tue, 10 Aug 2010 00:09:45 -0700 (PDT)
Message-ID: <20100810.000945.246516457.davem@davemloft.net>
References: <20100809164003.39c496ee.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51022
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753602Ab0HJHJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 03:09:26 -0400
In-Reply-To: <20100809164003.39c496ee.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 9 Aug 2010 16:40:03 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix etherdevice.h parameter name typo in kernel-doc:
> 
> Warning(include/linux/etherdevice.h:138): No description found for parameter 'hwaddr'
> Warning(include/linux/etherdevice.h:138): Excess function parameter 'addr' description in 'dev_hw_addr_random'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied.
