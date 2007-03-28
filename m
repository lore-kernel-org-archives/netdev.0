From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]: Fix ipv6 round-robin locking
Date: Wed, 28 Mar 2007 18:16:42 +0900 (JST)
Message-ID: <20070328.181642.47053702.yoshfuji@linux-ipv6.org>
References: <20070324.124436.104040932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35318 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965158AbXC1JP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 05:15:57 -0400
In-Reply-To: <20070324.124436.104040932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070324.124436.104040932.davem@davemloft.net> (at Sat, 24 Mar 2007 12:44:36 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> The fix for the most serious of them is below, and I'd appreciate
> any feedback if people spot any problems or holes in that approach.

I hoped we could save some memory per fib6_node,
but I'm fine with it.

Regards,

--yoshfuji
