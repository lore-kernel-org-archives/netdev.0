From: David Miller <davem@davemloft.net>
Subject: Re: [stable] net: drop dst before queueing fragments
Date: Fri, 26 Apr 2013 16:21:13 -0400 (EDT)
Message-ID: <20130426.162113.872341724759942153.davem@davemloft.net>
References: <20130418212842.GA18291@grsecurity.net>
	<1366596572.3408.138.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: spender@grsecurity.net, edumazet@google.com,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661Ab3DZUVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 16:21:17 -0400
In-Reply-To: <1366596572.3408.138.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 22 Apr 2013 03:09:32 +0100

> On Thu, 2013-04-18 at 17:28 -0400, Brad Spengler wrote:
>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=97599dc792b45b1669c3cdb9a4b365aad0232f65
>> 
>> Commit introducing error was from 2010, initial fix from 2011
>> 
>> Fix does not apply cleanly against 3.8 even
> 
> David, please add this to your stable queue.

I'm taking care of this right now, thanks Ben.
