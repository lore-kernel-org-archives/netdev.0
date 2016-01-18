From: Adam Seering <adam@seering.org>
Subject: Re: [PATCH] appletalk: Pass IP-over-DDP packets through when
 'ipddp0' interface is not present
Date: Sun, 17 Jan 2016 20:16:22 -0500
Message-ID: <1453079782.5666.19.camel@seering.org>
References: <1452832847.1707.42.camel@seering.org>
	 <20160117.192512.1143911903923641150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-03v.sys.comcast.net ([69.252.207.35]:49119 "EHLO
	resqmta-ch2-03v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753065AbcARBSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 20:18:36 -0500
In-Reply-To: <20160117.192512.1143911903923641150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> New features are not allowed to be submitted at this time because
> the net-next tree is closed.

Thanks for explaining; apologies.  I was following the instructions in
"Documentation/SubmittingPatches".

> 
> Please pay attention to the netdev mailing list announcements to
> learn when the net-next tree is open again and new features and
> cleanups are allowed to be submitted again.

Is the cadence described in "Documentation/networking/netdev-FAQ.txt"
accurate and sufficient?  (netdev is much too high-volume for me,
unfortunately.)
