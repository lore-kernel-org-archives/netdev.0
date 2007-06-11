From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT]: net-2.6.23 tree available
Date: Mon, 11 Jun 2007 13:12:08 +0200
Message-ID: <466D2E08.7030101@trash.net>
References: <20070610.181704.73383002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39887 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbXFKLOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 07:14:34 -0400
In-Reply-To: <20070610.181704.73383002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Get it while it's hot:
> 
> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.23.git
> 
> We have the qdisc_restart cleanup from Jama, some TIPC work
> from Allan Stephens and co., and Patrick's rtnl_link work.


I hope this still gives me the chance to submit updated patches
since I've changed a few things since the last submission and
a single incremental update would mix things that don't really
belong together.

BTW, I'm back from my trip, I'll work through all the comments
regarding these patches now.
