From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] tg3: Add tg3_netif_stop() in vlan functions
Date: Thu, 29 Jun 2006 20:12:43 -0700 (PDT)
Message-ID: <20060629.201243.95896478.davem@davemloft.net>
References: <1151630947.21798.17.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18402
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964942AbWF3DMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 23:12:44 -0400
To: mchan@broadcom.com
In-Reply-To: <1151630947.21798.17.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 29 Jun 2006 18:29:06 -0700

> Add tg3_netif_stop() when changing the vlgrp (vlan group) pointer. It
> is necessary to quiesce the device before changing that pointer.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Good catch.

Applied, thanks a lot Michael.
