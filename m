From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 10/12] tg3: implement ethtool set_phys_id
Date: Wed, 06 Apr 2011 14:32:11 -0700 (PDT)
Message-ID: <20110406.143211.57450239.davem@davemloft.net>
References: <20110404184340.604594357@linuxplumber.net>
	<20110404184502.194825403@linuxplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53221
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756512Ab1DFVcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:32:48 -0400
In-Reply-To: <20110404184502.194825403@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 04 Apr 2011 11:43:50 -0700

> Implement control of LED via set_phys_id. 
> Note: since PHY is powered off if device is down, this board
> only allows blinking if device is up.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
