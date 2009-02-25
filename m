From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] mv643xx_eth updates/fixes
Date: Tue, 24 Feb 2009 23:17:37 -0800 (PST)
Message-ID: <20090224.231737.71799166.davem@davemloft.net>
References: <20090225014125.GV17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759624AbZBYHR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:17:56 -0500
In-Reply-To: <20090225014125.GV17040@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Wed, 25 Feb 2009 02:41:25 +0100

> In this series:
> 1. Make LRO unconditional.
> 2. Convert to net_device_ops.
> 3. Fix bugs where link status is not accurately reported via ethtool
>    before the interface is up'd for the first time, and where rx/tx
>    coalescing timers are reset to zero every time you up the interface.
> 4. Set a sane default rx coalescing value.
> 
> Please consider for 2.6.30.  Thanks. :-)

All applied, thanks Lennert.
