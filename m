From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.38 Compile Failure e1000e Module
Date: Wed, 16 Mar 2011 11:15:08 -0700 (PDT)
Message-ID: <20110316.111508.59677457.davem@davemloft.net>
References: <20110316103318.19bd03e4.frank.peters@comcast.net>
	<1300288617.3202.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: frank.peters@comcast.net, linux-kernel@vger.kernel.org,
	bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58040
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751218Ab1CPSOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 14:14:31 -0400
In-Reply-To: <1300288617.3202.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Mar 2011 16:16:57 +0100

> [PATCH] e1000e: fix kconfig for crc32 dependency
> 
> ERROR: "crc32_le" [drivers/net/e1000e/e1000e.ko] undefined!
> 
> Reported-by: Frank Peters <frank.peters@comcast.net>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Eric.
