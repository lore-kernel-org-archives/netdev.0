From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Wed, 29 Aug 2007 11:15:34 -0700 (PDT)
Message-ID: <20070829.111534.40571057.davem@davemloft.net>
References: <20070828.220447.01366772.noboru.obata.ar@hitachi.com>
	<20070828.133057.107937654.davem@davemloft.net>
	<20070829.212613.65744831.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: noboru.obata.ar@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754282AbXH2SPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 14:15:35 -0400
In-Reply-To: <20070829.212613.65744831.noboru.obata.ar@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Date: Wed, 29 Aug 2007 21:26:13 +0900 (JST)

> From: David Miller <davem@davemloft.net>
> Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
> Date: Tue, 28 Aug 2007 13:30:57 -0700 (PDT)
> 
> > From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> > Date: Tue, 28 Aug 2007 22:04:47 +0900 (JST)
> > 
> > > (1) Make the application timeouts longer.  (Steve has shown that
> > >     making an application timeouts twice the failover detection
> > >     timeout would be a solution.)
> > 
> > This is the only feasible solution to your problem.
> 
> What about another option to let TCP have a notification?

No.
