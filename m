From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net 1/5] net_sched: remove the leftover cleanup_a()
Date: Tue, 9 Aug 2016 17:05:19 -0400
Message-ID: <1f652857-58a9-5a72-bcfb-5c8bf91827be@mojatatu.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
 <1470689209-17682-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35965 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932324AbcHIVFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:05:37 -0400
Received: by mail-qk0-f196.google.com with SMTP id x185so1931946qkc.3
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 14:05:36 -0700 (PDT)
In-Reply-To: <1470689209-17682-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-08 04:46 PM, Cong Wang wrote:
> After refactoring tc_action into tcf_common, we no
> longer need to cleanup temporary "actions" in list,
> they are permanently stored in the hashtable.
>
> Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Cong I will test these patches and provide feedback by end of day
or tommorrow morning.

cheers,
jamal
