From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 09/16] net: sched: make cls_u32 per cpu
Date: Wed, 10 Sep 2014 18:19:01 -0700
Message-ID: <1410398341.7106.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910155026.2036.4648.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:58860 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbaIKBTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 21:19:03 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so7646136pad.14
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 18:19:02 -0700 (PDT)
In-Reply-To: <20140910155026.2036.4648.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:50 -0700, John Fastabend wrote:
> This uses per cpu counters in cls_u32 in preparation
> to convert over to rcu.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
Acked-by: Eric Dumazet <edumazet@google.com>
