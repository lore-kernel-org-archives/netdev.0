From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: MPTCP Kernel Developer
Date: Thu, 09 Apr 2015 19:00:14 -0700
Message-ID: <1428631214.25985.287.camel@edumazet-glaptop2.roam.corp.google.com>
References: <f051a496e9094a9dae72e2183a82817e@mail.vUnity.com>
	 <20150409.202637.1489346008975456388.davem@davemloft.net>
	 <bde533c5bbef43b6815e8cbdf51b6365@mail.vUnity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <octavian.purdila@intel.com>
To: Brian Brandon <Brian@vUnity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37730 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbbDJCAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 22:00:17 -0400
Received: by igblo3 with SMTP id lo3so7022390igb.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 19:00:16 -0700 (PDT)
In-Reply-To: <bde533c5bbef43b6815e8cbdf51b6365@mail.vUnity.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-10 at 01:29 +0000, Brian Brandon wrote:
> David,
> 
> We have been successful building a new unreliable MPTCP and the RTT
> packet scheduler functions correctly with retransmits while discarding
> the acknowledgement (thereby avoiding the dreaded TCP Congestion
> Collapse.) However, we can't get it stable in the Linux kernel yet. 

No idea why a proxy should be in linux kernel ...

> We believe a scalable MPTCP proxy is of major significance and we're
> contributing everything we build back to the community. -- it's not
> some corporate headhunt stuff. We're honestly just stuck for now and
> didn't know where else to turn but back to the community for some
> help. 
> 
> -Brian

Please do not top post on netdev.

Honestly, you should talk to MPTCP guys.

Octavian Octavian Purdila gave a talk about MPTCP in Ottawa last
February.
