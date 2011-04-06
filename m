From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] bnx2x: convert to set_phys_id
Date: Wed, 06 Apr 2011 14:36:24 -0700 (PDT)
Message-ID: <20110406.143624.220048580.davem@davemloft.net>
References: <20110404210634.840793593@linuxplumber.net>
	<20110404210805.493178297@linuxplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, eilong@broadcom.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42445
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932333Ab1DFVhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:37:01 -0400
In-Reply-To: <20110404210805.493178297@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 04 Apr 2011 14:06:37 -0700

> Also cleanup error codes to no lie about things that driver doesn't
> support. If device is down report -EAGAIN (same as Broadcom), and 
> if port doesn't blink then error as well.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
