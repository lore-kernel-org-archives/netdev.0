From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net 1/2] sch_pie: schedule the timer after all init
 succeed
Date: Fri, 24 Oct 2014 17:17:02 -0700
Message-ID: <1414196222.20845.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Vijay Subramanian <vijaynsu@cisco.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:61150 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYARD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:17:03 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so2013689pab.6
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:17:03 -0700 (PDT)
In-Reply-To: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-24 at 16:55 -0700, Cong Wang wrote:
> Cc: Vijay Subramanian <vijaynsu@cisco.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/sch_pie.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Not sure why you use "Cc: David S. Miller <davem@davemloft.net>",
given that all networking patches have "Signed-off-by: David S. Miller
<davem@davemloft.net>" ???
