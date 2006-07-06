From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/3] Action API fixes
Date: Thu, 06 Jul 2006 08:53:53 -0400
Message-ID: <1152190433.5103.41.camel@jzny2>
References: <20060704220504.787776000@postel.suug.ch>
	 <20060705.204751.112605889.davem@davemloft.net>
	 <1152187428.5103.6.camel@jzny2> <1152188854.5103.17.camel@jzny2>
	 <20060706124539.GZ14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:42718 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030256AbWGFMxz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 08:53:55 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FyTMj-0000gO-FE
	for netdev@vger.kernel.org; Thu, 06 Jul 2006 08:53:57 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060706124539.GZ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-07 at 14:45 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-07-06 08:27
> > 
> > The proper patch is attached as a replacement for 
> > "[PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping action"
> > from Thomas. 
> > If you have already submitted it, then i will send a patch against it.
> 
> I don't understand why you're picky about this but if you really
> want to then do it properly and remove the now unused err variable,
> don't leave obscure code behind again.

For heavens sake, do we have to argue even about this? 
look at the code calmly and rationally and tell me if your fix was even
close to right. It was a bug. All bugs are obscure.

cheers,
jamal

