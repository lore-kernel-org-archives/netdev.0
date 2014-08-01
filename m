From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv6: addrconf: clean up device type handling
Date: Thu, 31 Jul 2014 22:31:10 -0700 (PDT)
Message-ID: <20140731.223110.1134366032001151674.davem@davemloft.net>
References: <1406840034-140848-1-git-send-email-equinox@diac24.net>
	<1406840034-140848-3-git-send-email-equinox@diac24.net>
	<1406844815.13603.24.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: equinox@diac24.net, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbaHAFbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:31:11 -0400
In-Reply-To: <1406844815.13603.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 01 Aug 2014 00:13:35 +0200

> David, can you respin this series without the macros and maybe add the
> 
> "case ARPHRD_IP6GRE:" stuff
> 
> as a separate patch (which should also go into net/stable). If you don't
> want to do this, I also can take care of this, no problem.
> 
> You can then repost this one separate and state in the comment section
> that this cleanup patch depends on the other two, so Dave can merge it
> accordingly to net and net-next?

Indeed, please respin this series making the target tree(s) more
explicit, thanks.
