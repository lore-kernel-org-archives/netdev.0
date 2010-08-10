From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] phy.c: fix kernel-doc warnings
Date: Tue, 10 Aug 2010 00:09:56 -0700 (PDT)
Message-ID: <20100810.000956.102569897.davem@davemloft.net>
References: <20100809164159.c81cd1c4.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753602Ab0HJHJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 03:09:37 -0400
In-Reply-To: <20100809164159.c81cd1c4.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 9 Aug 2010 16:41:59 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix phy.c kernel-doc notation:
> 
> Warning(drivers/net/phy/phy.c:313): No description found for parameter 'ifr'
> Warning(drivers/net/phy/phy.c:313): Excess function parameter 'mii_data' description in 'phy_mii_ioctl'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied.
