From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 00/10]: ktime clocksource + hrtimer
Date: Fri, 16 Mar 2007 10:42:26 +0100
Message-ID: <45FA6682.10303@trash.net>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain> <20070316.023510.41635847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49486 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933262AbXCPJma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 05:42:30 -0400
In-Reply-To: <20070316.023510.41635847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> All 11 patches applied and pushed out, very very nice work
> Patrick!

Thanks Dave :)

> It would be nice to figure out why CBQ isn't working for
> you, I know at least some folks have used it successfully
> at some point.

Probably my own incompetence, I'll see if I can find some
scripts that are known to work.

