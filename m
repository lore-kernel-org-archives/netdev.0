From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v4 1/7] net_sched: remove the leftover cleanup_a()
Date: Sun, 14 Aug 2016 07:01:11 -0400
Message-ID: <197c1500-9bb7-4bec-c3a9-1a232a3c771f@mojatatu.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
 <1471152902-12444-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35258 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933412AbcHNLBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 07:01:13 -0400
Received: by mail-qk0-f181.google.com with SMTP id v123so23104980qkh.2
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 04:01:12 -0700 (PDT)
In-Reply-To: <1471152902-12444-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-14 01:34 AM, Cong Wang wrote:
> After refactoring tc_action into tcf_common, we no
> longer need to cleanup temporary "actions" in list,
> they are permanently stored in the hashtable.
>
> Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
