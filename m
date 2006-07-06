From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/3] Action API fixes
Date: Thu, 6 Jul 2006 14:45:39 +0200
Message-ID: <20060706124539.GZ14627@postel.suug.ch>
References: <20060704220504.787776000@postel.suug.ch> <20060705.204751.112605889.davem@davemloft.net> <1152187428.5103.6.camel@jzny2> <1152188854.5103.17.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:34695 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965190AbWGFMpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 08:45:19 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1152188854.5103.17.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-07-06 08:27
> 
> The proper patch is attached as a replacement for 
> "[PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping action"
> from Thomas. 
> If you have already submitted it, then i will send a patch against it.

I don't understand why you're picky about this but if you really
want to then do it properly and remove the now unused err variable,
don't leave obscure code behind again.
