From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 00/50] 2.6.25.6 -stable review
Date: Sun, 08 Jun 2008 16:07:47 -0400
Message-ID: <484C3C13.7020609@garzik.org>
References: <20080607204325.GJ5609@1wt.eu>	<BAY103-DAV7370611E1B3FEA8FD69B9B2B10@phx.gbl>	<20080608123601.GB10491@1wt.eu>	<20080608.071051.212882594.davem@davemloft.net> <20080608103835.0c0b1e83@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, w@1wt.eu, pupilla@hotmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	chrisw@sous-sol.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54293 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756109AbYFHUH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 16:07:56 -0400
In-Reply-To: <20080608103835.0c0b1e83@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> On Sun, 08 Jun 2008 07:10:51 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> 
>> If you ask me in the future about the status of a -stable
>> patch from the networking, I'll let you know exactly what
>> is happening to that patch wrt. stable.  I rarely forget
>> to submit an appropriate patch, and when I do forget you
>> merely have to let me know (rather than submitting it
>> to -stable directly, please don't do that) so that I can
>> fit it in with what I plan to submit to -stable already.
> 
> 
> As a netdev driver maintainer, I've been following this workflow for
> patches that need to go to -stable:
> 
> 1.  I submit a mainline patch to Jeff Garzik.
> 2.  Jeff submits to David.
> 3.  David submits to Linus.
> 4.  Linus merges patch into mainline.
> 5.  I extract mainline commit ID.
> 6.  I apply and test patch against appropriate 2.6.x.y git tree.
> 7.  I submit patch directly to -stable.
> 
> David's admonition tells me I'm doing it wrong, and that I should
> submit the stable patch to Jeff as well.  Am I right?

I usually encourage a more-parallel process where you simply email 
stable@kernel.org with the upstream commit id of the change(s) in question.

	Jeff



