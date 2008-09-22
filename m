From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
	feature-negotiation patches
Date: Mon, 22 Sep 2008 08:28:07 +0200
Message-ID: <20080922062807.GA12068@gerrit.erg.abdn.ac.uk>
References: <20080903042450.GA4105@gerrit.erg.abdn.ac.uk> <20080902.230655.89921076.davem@davemloft.net> <20080922045744.GA6889@gerrit.erg.abdn.ac.uk> <20080921.220948.140018058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:39331 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750764AbYIVG22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 02:28:28 -0400
Content-Disposition: inline
In-Reply-To: <20080921.220948.140018058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| There are two paths forward at the current point in time.
| 
| 1) You submit a very small group of patches at a time to me.
|    I'm talking like 5 or 6 patches at a time, maximum.
| 
|    And I'm going to give extra amounts of personal review to
|    these, so it will take even more time than usual.
| 
Further review can never harm, so I am sure this will be good.

I have a question regarding granularity - the current granularity is
meant to be logical, but is low.
It is easy to get distracted by the details since at the end of
the day the 37 patches achieve a rewriting of feat.c in small steps.

Would you therefore be ok with me combining some of the patches or would
you prefer to review the set at its current granularity?

Thanks
Gerrit
