From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 00/14] pktgen update for net-next (2.6.32)
Date: Wed, 9 Sep 2009 09:53:50 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909090937550.9377@ask.diku.dk>
References: <20090827235506.624381734@vyatta.com> <19110.17776.721680.242313@gargle.gargle.HOWL>
 <Pine.LNX.4.64.0909081409210.20285@ask.diku.dk> <19110.31505.134937.813631@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:54696 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbZIIHxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 03:53:49 -0400
In-Reply-To: <19110.31505.134937.813631@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Sep 2009, robert@herjulf.net wrote:

>> With patches:
>> -------------
>> tx_pkt_sz: 64  TX-pps: 9426724
>
> Impressive. 82599 seems fast. Didn't you report even higher number
> with other CPU's?

Yes, the Core i7 is even faster... but currently I'm not using it as a 
generator, its the router in my current setup.

Once I have finished my slides and last tests for LinuxCon.  I'll run some 
pktgen tests with the Core i7 and post the results.

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
