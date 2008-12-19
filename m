From: David Miller <davem@davemloft.net>
Subject: Re: [RFCv2][PATCH] static builtin CCIDs was Re: [PATCH 2/5] dccp:
 Auto-load (when supported) CCID plugins for negotiation
Date: Thu, 18 Dec 2008 22:28:42 -0800 (PST)
Message-ID: <20081218.222842.174783235.davem@davemloft.net>
References: <20081218053349.GA6172@gerrit.erg.abdn.ac.uk>
	<20081218.191534.194793981.davem@davemloft.net>
	<20081219052446.GA3651@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, mirqus@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54133
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbYLSG2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 01:28:41 -0500
In-Reply-To: <20081219052446.GA3651@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 19 Dec 2008 06:24:46 +0100

> | > | Gerrit, are you OK with this?
> | > | 
> | > Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> | 
> | Applied, thanks everyone.
> | 
> I am sorry but I have to revert the Acked-by. As per
> yesterday's email I was ok with the basic idea, but
> already said that this did not include testing.
> 
> Please do not apply this patch yet, it introduces several
> new problems and needs more work.

You are so incredibly lucky I didn't push this out to kernel.org yet,
it's been sitting in my tree all day long.

Don't say ACK unless you mean it.

It's reverted but you should do real reviews before you ACK changes in
the future.

