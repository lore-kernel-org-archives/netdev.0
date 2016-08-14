From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v4 3/7] net_sched: fix a typo in tc_for_each_action()
Date: Sun, 14 Aug 2016 07:02:24 -0400
Message-ID: <34f16402-2568-4c90-7496-e9be7ae54064@mojatatu.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
 <1471152902-12444-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amir@vadai.me>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34415 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964878AbcHNLC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 07:02:26 -0400
Received: by mail-qk0-f193.google.com with SMTP id n66so310512qkf.1
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 04:02:25 -0700 (PDT)
In-Reply-To: <1471152902-12444-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-14 01:34 AM, Cong Wang wrote:
> It is harmless because all users pass 'a' to this macro.
>
> Fixes: 00175aec941e ("net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef")
> Cc: Amir Vadai <amir@vadai.me>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
