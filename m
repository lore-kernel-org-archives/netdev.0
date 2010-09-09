From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.32.21 bnx2_napi->hw_tx_cons_ptr NULL pointer
 dereference
Date: Wed, 08 Sep 2010 21:58:09 -0700 (PDT)
Message-ID: <20100908.215809.232892441.davem@davemloft.net>
References: <20100909013437.GA6400@lintop>
	<C27F8246C663564A84BB7AB3439772421B9134BA2E@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.bohrer@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60306
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750905Ab0IIE5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 00:57:52 -0400
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B9134BA2E@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 8 Sep 2010 21:55:29 -0700

> Shawn Bohrer wrote:
> 
>> Is there any reason these can't/shouldn't be applied to the 2.6.32.y
>> stable series?  It looks like they apply cleanly.
>>
> 
> No reason.  I just didn't know how far back to apply these patches.
> The crash was triggered by changes in netpoll some time ago and
> the problem has been present for some time.

Michael, please submit these to -stable then, thanks!
