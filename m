From: David Miller <davem@davemloft.net>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Sat, 17 Jun 2006 21:08:18 -0700 (PDT)
Message-ID: <20060617.210818.65908721.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC041BD1E@NT-IRVA-0751.brcm.ad.broadcom.com>
	<1150568608.26368.49.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jk@blackdown.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4551
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932082AbWFREHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 00:07:47 -0400
To: mchan@broadcom.com
In-Reply-To: <1150568608.26368.49.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 17 Jun 2006 11:23:28 -0700

> David, Here's the patch if you haven't already made one:
> 
> [TG3]: Disable TSO by default on 5780 class chips.

Sorry, I didn't get a chance to push this into 2.6.17
in time.  I will push it into the first 2.6.17.x -stable
release.
