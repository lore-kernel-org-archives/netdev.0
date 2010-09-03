From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 3/3] be2net: remove a BUG_ON in be_cmds.c
Date: Fri, 03 Sep 2010 09:54:01 -0700 (PDT)
Message-ID: <20100903.095401.71567840.davem@davemloft.net>
References: <20100903162403.GA22851@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756279Ab0ICQxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:53:44 -0400
In-Reply-To: <20100903162403.GA22851@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 3 Sep 2010 21:54:13 +0530

> Async notifications other than link status are possible in certain
> configurations. Remove the BUG_ON in the mcc completion processing path.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
