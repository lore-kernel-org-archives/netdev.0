From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 2/4] net/sched: act_mirred: Refactor detection
 whether dev needs xmit at mac header
Date: Thu, 13 Oct 2016 07:56:45 -0400
Message-ID: <d4c95e79-bff7-a3b8-976f-0384db813aa9@mojatatu.com>
References: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
 <1476338804-25440-3-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36460 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754647AbcJML5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 07:57:40 -0400
Received: by mail-io0-f195.google.com with SMTP id o141so4756148ioe.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 04:56:47 -0700 (PDT)
In-Reply-To: <1476338804-25440-3-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-13 02:06 AM, Shmulik Ladkani wrote:
> Move detection logic that tests whether device expects skb data to point
> at mac_header upon xmit into a function.
>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
