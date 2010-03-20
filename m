From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] IPv6: addrconf cleanup addrconf_verify
Date: Sat, 20 Mar 2010 16:13:11 -0700 (PDT)
Message-ID: <20100320.161311.241461332.davem@davemloft.net>
References: <20100318063108.109693694@vyatta.com>
	<20100318063123.441975388@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42392
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752515Ab0CTXMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 19:12:48 -0400
In-Reply-To: <20100318063123.441975388@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Mar 2010 23:31:17 -0700

> The variable regen_advance is only used in the privacy case.
> Move it to simplify code and eliminate ifdef's
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
