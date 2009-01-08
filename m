From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Thu, 08 Jan 2009 10:45:09 -0800 (PST)
Message-ID: <20090108.104509.252873998.davem@davemloft.net>
References: <87r63gu1i3.fsf@macbook.be.48ers.dk>
	<20090107045258.GA8071@localhost>
	<874p0bmsl0.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, netdev@vger.kernel.org
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754187AbZAHSpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:45:07 -0500
In-Reply-To: <874p0bmsl0.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Wed, 07 Jan 2009 09:24:43 +0100

> >>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:
> 
>  Wu> dm9601: tell HW about random generated mac address
> 
>  Wu> Otherwise unicast RX will only work in promisc mode.
> 
>  Wu> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
>  Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied, thanks everyone.
