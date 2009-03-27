From: David Miller <davem@davemloft.net>
Subject: Re: [patch 22/30] netdev: convert at1700 to net_device_ops
Date: Fri, 27 Mar 2009 00:52:02 -0700 (PDT)
Message-ID: <20090327.005202.126956981.davem@davemloft.net>
References: <20090327011114.169107105@linux-foundation.org>
	<20090327011256.531097944@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754383AbZC0HwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:52:14 -0400
In-Reply-To: <20090327011256.531097944@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 26 Mar 2009 18:11:36 -0700

> Remove unneeded memset (alloc_etherdev does it already).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
