From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] tg3: Add rx BD workaround
Date: Thu, 29 Jun 2006 20:14:43 -0700 (PDT)
Message-ID: <20060629.201443.35467975.davem@davemloft.net>
References: <1151630955.21798.18.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6114
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964943AbWF3DOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 23:14:44 -0400
To: mchan@broadcom.com
In-Reply-To: <1151630955.21798.18.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 29 Jun 2006 18:29:14 -0700

> Add workaround to limit the burst size of rx BDs being DMA'ed to the
> chip.  This works around hardware errata on a number of 5750, 5752,
> and 5755 chips.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Ugly bug, but what can we do? :-)

Applied, thanks.
