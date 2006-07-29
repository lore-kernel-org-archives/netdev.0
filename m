From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Sat, 29 Jul 2006 13:28:47 +0900 (JST)
Message-ID: <20060729.132847.15557224.yoshfuji@linux-ipv6.org>
References: <20060726221849.495778268@postel.suug.ch>
	<20060729.131306.80352422.yoshfuji@linux-ipv6.org>
	<20060728.211428.26968121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, anttit@tcs.hut.fi,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:23047 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1161449AbWG2E1V
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 00:27:21 -0400
To: davem@davemloft.net
In-Reply-To: <20060728.211428.26968121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060728.211428.26968121.davem@davemloft.net> (at Fri, 28 Jul 2006 21:14:28 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> For now I would suggest we use Thomas's approach, and we
> can make performance measurements to determine if it makes
> to optimize this or consider other methods.

Okay.

--yoshfuji
