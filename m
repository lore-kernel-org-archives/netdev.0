From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v5 00/16] net/sched rcu filters
Date: Fri, 12 Sep 2014 19:49:51 -0700
Message-ID: <1410576591.7106.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
	 <20140912.223644.1321799741112871913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, xiyou.wangcong@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:38696 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbaIMCt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 22:49:56 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so2517358pad.21
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 19:49:56 -0700 (PDT)
In-Reply-To: <20140912.223644.1321799741112871913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 22:36 -0400, David Miller wrote:
> John you're getting really close with this series.
> 
> Why don't you post everything up to the tc actions stuff,
> which Eric has ACK'd already, and I can put that all into
> the net-next tree right now.
> 
> Then you can concentrate on the bits that remain without
> having to post the other stuff over and over again.


+2  ;)
