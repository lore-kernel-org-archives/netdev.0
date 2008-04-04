From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][TG3]: Add PHY workaround for 5784
Date: Thu, 03 Apr 2008 21:45:21 -0700 (PDT)
Message-ID: <20080403.214521.145141698.davem@davemloft.net>
References: <1207282049.5625.3.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35039
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751116AbYDDEpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 00:45:20 -0400
In-Reply-To: <1207282049.5625.3.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 Apr 2008 20:07:29 -0800

> [TG3]: Add PHY workaround for 5784
> 
> The 5784 B step and newer chips require the PHY DSPs to be fine-tuned
> based on one-time programmable values stored in the chip.  This is
> essential to achieve optimal PHY operations especially when using
> long cables.  We also need to properly handle the 10Mbit RX bit in the
> CPMU_CTRL register during PHY reset.
> 
> Update version to 3.89.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
