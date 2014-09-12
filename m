From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v5 11/16] net: sched: rcu'ify cls_rsvp
Date: Fri, 12 Sep 2014 11:21:15 -0700
Message-ID: <1410546075.7106.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
	 <20140912163312.19588.84899.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:50750 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaILSVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 14:21:17 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so1790409pad.28
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 11:21:17 -0700 (PDT)
In-Reply-To: <20140912163312.19588.84899.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 09:33 -0700, John Fastabend wrote:
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_rsvp.h |  160 ++++++++++++++++++++++++++++----------------------
>  1 file changed, 90 insertions(+), 70 deletions(-)
> 

Acked-by: Eric Dumazet <edumazet@google.com>
