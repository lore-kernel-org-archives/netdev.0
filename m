From: David Miller <davem@davemloft.net>
Subject: Re: [patch 30/30] netdev: convert eth16i to net_device_ops
Date: Fri, 27 Mar 2009 00:52:51 -0700 (PDT)
Message-ID: <20090327.005251.57010988.davem@davemloft.net>
References: <20090327011114.169107105@linux-foundation.org>
	<20090327011257.104894196@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755512AbZC0HxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:53:03 -0400
In-Reply-To: <20090327011257.104894196@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 26 Mar 2009 18:11:44 -0700

> Also, get rid of unnecessary memset.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
