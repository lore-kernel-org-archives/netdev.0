From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 7/8] net_sched: convert tc_action_ops to use
 struct list_head
Date: Wed, 18 Dec 2013 09:40:54 -0500
Message-ID: <52B1B3F6.4070804@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com> <1387167311-14763-8-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:43373 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577Ab3LROk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:40:58 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so10362467iec.13
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:40:58 -0800 (PST)
In-Reply-To: <1387167311-14763-8-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/13 23:15, Cong Wang wrote:
> We don't need to maintain our own singly linked list code.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

nice!

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
