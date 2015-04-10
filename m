From: Brian Brandon <Brian@vUnity.com>
Subject: RE: MPTCP Kernel Developer
Date: Fri, 10 Apr 2015 01:29:52 +0000
Message-ID: <bde533c5bbef43b6815e8cbdf51b6365@mail.vUnity.com>
References: <f051a496e9094a9dae72e2183a82817e@mail.vUnity.com>
 <20150409.202637.1489346008975456388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vunity.com ([199.36.31.80]:10236 "EHLO mail.vUnity.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038AbbDJBcN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 21:32:13 -0400
In-Reply-To: <20150409.202637.1489346008975456388.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

We have been successful building a new unreliable MPTCP and the RTT packet scheduler functions correctly with retransmits while discarding the acknowledgement (thereby avoiding the dreaded TCP Congestion Collapse.) However, we can't get it stable in the Linux kernel yet. 

We believe a scalable MPTCP proxy is of major significance and we're contributing everything we build back to the community. -- it's not some corporate headhunt stuff. We're honestly just stuck for now and didn't know where else to turn but back to the community for some help. 

-Brian

Brian J. Brandon
CCNP | MCSE:Security | MCITP:EA
Bandwidth | Reliability | Efficiency | Unified 

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Thursday, April 09, 2015 5:27 PM
To: Brian Brandon
Cc: netdev@vger.kernel.org
Subject: Re: MPTCP Kernel Developer

From: Brian Brandon <Brian@vUnity.com>
Date: Thu, 9 Apr 2015 22:58:35 +0000

> Anybody know a veteran Linux kernel developer available for some part 
> time work?

This is absolutely not appropriate for this mailing list.

Please do not do this again.
