From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 01/15] net: qdisc: use rcu prefix and silence
 sparse warnings
Date: Thu, 15 May 2014 16:43:46 -0400 (EDT)
Message-ID: <20140515.164346.947715567183206041.davem@davemloft.net>
References: <20140430163250.9021.21199.stgit@nitbit.x32>
	<20140430163504.9021.12828.stgit@nitbit.x32>
	<5373C660.7030301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, paulmck@linux.vnet.ibm.com,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbaEOUns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 16:43:48 -0400
In-Reply-To: <5373C660.7030301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 14 May 2014 12:39:12 -0700

> At the moment I'm not seeing what changed that would cause the error.
> Any ideas what I got wrong here?

John I took a quick look at this and I'm as mystified as you are :-/

Maybe Paul can provide some insight.
