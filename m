From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] ipv6: icmp6_dst_gc return change
Date: Tue, 22 Jul 2008 14:35:59 -0700 (PDT)
Message-ID: <20080722.143559.230900195.davem@davemloft.net>
References: <20080722212927.937523165@vyatta.com>
	<20080722212951.875449888@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56362
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752010AbYGVVf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:35:59 -0400
In-Reply-To: <20080722212951.875449888@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 22 Jul 2008 14:29:32 -0700

> Change icmp6_dst_gc to return the one value the caller cares about rather
> than using call by reference.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Also applied, thanks.
