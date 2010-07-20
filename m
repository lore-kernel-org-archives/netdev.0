From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] bnx2: Use proper counter for
 net_device_stats->multicast.
Date: Mon, 19 Jul 2010 20:31:06 -0700 (PDT)
Message-ID: <20100719.203106.37552664.davem@davemloft.net>
References: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758185Ab0GTDau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 23:30:50 -0400
In-Reply-To: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 19 Jul 2010 17:15:02 -0700

> We were using the wrong tx multicast counter instead of the rx multicast
> counter.
> 
> Reported-by: Peter Snellman <peter.snellman@cinnober.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
