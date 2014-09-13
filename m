From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v5 00/16] net/sched rcu filters
Date: Fri, 12 Sep 2014 22:36:44 -0400 (EDT)
Message-ID: <20140912.223644.1321799741112871913.davem@davemloft.net>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbaIMCgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 22:36:48 -0400
In-Reply-To: <20140912162748.19588.39677.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


John you're getting really close with this series.

Why don't you post everything up to the tc actions stuff,
which Eric has ACK'd already, and I can put that all into
the net-next tree right now.

Then you can concentrate on the bits that remain without
having to post the other stuff over and over again.

Thanks.
