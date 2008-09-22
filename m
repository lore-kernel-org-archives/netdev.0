From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
 feature-negotiation patches
Date: Sun, 21 Sep 2008 23:58:53 -0700 (PDT)
Message-ID: <20080921.235853.223987556.davem@davemloft.net>
References: <20080922045744.GA6889@gerrit.erg.abdn.ac.uk>
	<20080921.220948.140018058.davem@davemloft.net>
	<20080922062807.GA12068@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751050AbYIVG7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 02:59:05 -0400
In-Reply-To: <20080922062807.GA12068@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 22 Sep 2008 08:28:07 +0200

> | There are two paths forward at the current point in time.
> | 
> | 1) You submit a very small group of patches at a time to me.
> |    I'm talking like 5 or 6 patches at a time, maximum.
> | 
> |    And I'm going to give extra amounts of personal review to
> |    these, so it will take even more time than usual.
> | 
> Further review can never harm, so I am sure this will be good.
> 
> I have a question regarding granularity - the current granularity is
> meant to be logical, but is low.
> It is easy to get distracted by the details since at the end of
> the day the 37 patches achieve a rewriting of feat.c in small steps.
> 
> Would you therefore be ok with me combining some of the patches or would
> you prefer to review the set at its current granularity?

Current granularity.

So, submit about 5 pieces at a time, you can say at the beginning of
the series (in the [PATCH 0/X]: email) something like "this is phase N
in the rewriting of feat.c which will achieve X Y and Z"
