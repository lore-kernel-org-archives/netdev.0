From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] bnx2: convert to set_phys_id
Date: Wed, 06 Apr 2011 14:36:18 -0700 (PDT)
Message-ID: <20110406.143618.71565093.davem@davemloft.net>
References: <20110404210634.840793593@linuxplumber.net>
	<20110404210805.389777981@linuxplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, mchan@broadcom.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42438
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932323Ab1DFVgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:36:55 -0400
In-Reply-To: <20110404210805.389777981@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 04 Apr 2011 14:06:36 -0700

> In this case, need to add element to device private to hold
> original led state.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
