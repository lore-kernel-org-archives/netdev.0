From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 01/04]: Remove CONFIG_NET_ESTIMATOR option
Date: Mon, 02 Jul 2007 22:46:44 -0700 (PDT)
Message-ID: <20070702.224644.41949497.davem@davemloft.net>
References: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
	<20070619150200.30997.73722.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43480
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751479AbXGCFqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 01:46:24 -0400
In-Reply-To: <20070619150200.30997.73722.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 19 Jun 2007 17:02:19 +0200 (MEST)

> [NET_SCHED]: Remove CONFIG_NET_ESTIMATOR option
> 
> The generic estimator is always built in anways and all the config options
> does is prevent including a minimal amount of code for setting it up.
> Additionally the option is already automatically selected for most cases.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
