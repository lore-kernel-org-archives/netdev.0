From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 23:28:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1004222323020.11449@ask.diku.dk>
References: <1271941082.14501.189.camel@jdb-workstation>
 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
 <1271948029.7895.5707.camel@edumazet-laptop>  <20100422155123.GA2524@linux.vnet.ibm.com>
  <1271952128.7895.5851.camel@edumazet-laptop>  <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
 <1271970199.7895.6482.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Patrick McHardy <kaber@trash.net>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:38554 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755754Ab0DVV2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 17:28:21 -0400
In-Reply-To: <1271970199.7895.6482.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Apr 2010, Eric Dumazet wrote:

> What exact version of kernel are you running ?

2.6.31.7-pvlan2G #3 SMP PREEMPT
32-bit kernel with 2G kernel mem (you showed me that trick).

I have some patches on top (which are accepted upstream), but I originate 
from commit f8ebcb2ebc49a Linux 2.6.31.7.


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
