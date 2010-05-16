From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] bridge: netfilter use net_ratelimit
Date: Sat, 15 May 2010 23:12:23 -0700 (PDT)
Message-ID: <20100515.231223.124044249.davem@davemloft.net>
References: <20100510193107.722574297@vyatta.com>
	<20100510193320.936126854@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751827Ab0EPGMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:12:15 -0400
In-Reply-To: <20100510193320.936126854@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 10 May 2010 12:31:10 -0700

> The function __br_dnat_complain is basically reimplementing existing
> net_ratelimit.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

This code is no longer there after the recent netfilter merges.
