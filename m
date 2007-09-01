From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2]: [NET_SCHED]: Making rate table lookups more flexible.
Date: Sat, 01 Sep 2007 09:10:58 +0200
Message-ID: <46D91082.7050609@trash.net>
References: <1188562978.18622.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48303 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbXIAHM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 03:12:29 -0400
In-Reply-To: <1188562978.18622.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> commit ac093f5c2f1160ece72a6fef5c779c1892fc3152
> Author: Jesper Dangaard Brouer <hawk@comx.dk>
> Date:   Fri Aug 31 11:53:35 2007 +0200
> 
>     [NET_SCHED]: Making rate table lookups more flexible.  Extend the
>     tc_ratespec struct, with two parameters: 1) "cell_align" that allow
>     adjusting the alignment of the rate table. 2) "overhead" that allow
>     adding a packet overhead before the lookup.


Am I guessing right that the intention is to resurrect the ATM patch?

