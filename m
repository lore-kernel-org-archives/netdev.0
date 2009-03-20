From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: add new value for DHCP added routes
Date: Thu, 19 Mar 2009 23:49:51 -0700 (PDT)
Message-ID: <20090319.234951.169680930.davem@davemloft.net>
References: <20090318122714.5d36d62f@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751577AbZCTGuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 02:50:04 -0400
In-Reply-To: <20090318122714.5d36d62f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 Mar 2009 12:27:14 -0700

> To improve manageability, it would be good to be able to disambiguate routes
> added by administrator from those added by DHCP client.  The only necessary
> kernel change is to add value to rtnetlink include file so iproute2 utility
> can use it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6, thanks.
