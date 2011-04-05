From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] bridge enhancements for net-next
Date: Mon, 04 Apr 2011 17:23:45 -0700 (PDT)
Message-ID: <20110404.172345.176648873.davem@davemloft.net>
References: <20110405000326.714524584@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38155
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807Ab1DEAYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 20:24:22 -0400
In-Reply-To: <20110405000326.714524584@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 04 Apr 2011 17:03:26 -0700

> These patches add more netlink support for bridge.
> It is possible to do basic configuration bridge with just netlink.
> Later enhancements will add statistics and parameters.
> 
> The intention is to switch to pure netlink in future and support
> RSTP and deprecate the old ioctl, sysfs and STP code.

Looks good, all applied, thanks Stephen.
