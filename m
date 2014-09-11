From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 05/16] net: sched: cls_flow use RCU
Date: Wed, 10 Sep 2014 17:58:52 -0700
Message-ID: <1410397132.7106.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910154837.2036.83248.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:53157 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbaIKA6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 20:58:54 -0400
Received: by mail-pd0-f178.google.com with SMTP id p10so9262977pdj.9
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 17:58:54 -0700 (PDT)
In-Reply-To: <20140910154837.2036.83248.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:48 -0700, John Fastabend wrote:
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_flow.c |  145 +++++++++++++++++++++++++++++---------------------
>  1 file changed, 84 insertions(+), 61 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
