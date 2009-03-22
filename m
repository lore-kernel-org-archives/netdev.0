From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 52/77] sbni: use internal net_device_stats
Date: Sat, 21 Mar 2009 22:47:31 -0700 (PDT)
Message-ID: <20090321.224731.260042135.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053716.500120634@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751447AbZCVFrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 01:47:43 -0400
In-Reply-To: <20090321053716.500120634@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:36:19 -0700

> Convert to use existing net_device_stats.
> This driver,
>       has bad style,
>       	of using commas,
> 	   when brackets should be used...
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
