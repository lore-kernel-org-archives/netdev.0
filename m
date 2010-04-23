From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 09:23:43 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004230922120.24961@obet.zrqbmnf.qr>
References: <1271941082.14501.189.camel@jdb-workstation>  <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>  <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>  <1271948029.7895.5707.camel@edumazet-laptop>
 <20100422155123.GA2524@linux.vnet.ibm.com>  <1271952128.7895.5851.camel@edumazet-laptop>  <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk> <1271970199.7895.6482.camel@edumazet-laptop> <Pine.LNX.4.64.1004222323020.11449@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:57211 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753034Ab0DWHXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 03:23:44 -0400
In-Reply-To: <Pine.LNX.4.64.1004222323020.11449@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2010-04-22 23:28, Jesper Dangaard Brouer wrote:

> On Thu, 22 Apr 2010, Eric Dumazet wrote:
>
>> What exact version of kernel are you running ?
>
> 2.6.31.7-pvlan2G #3 SMP PREEMPT
> 32-bit kernel with 2G kernel mem (you showed me that trick).

Since when is enabling 2G a trick? :)
There's CONFIG_VMSPLIT_2G (and 2G_OPT) for quite some time now.

