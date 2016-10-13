From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Thu, 13 Oct 2016 07:58:13 -0400
Message-ID: <d9e1ed21-9a3a-179f-fc5b-4b85631db038@mojatatu.com>
References: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
 <1476338804-25440-5-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36448 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755082AbcJMMLJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 08:11:09 -0400
Received: by mail-it0-f67.google.com with SMTP id o19so5702161ito.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 05:11:01 -0700 (PDT)
In-Reply-To: <1476338804-25440-5-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-13 02:06 AM, Shmulik Ladkani wrote:
> Up until now, 'action mirred' supported only egress actions (either
> TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).
>
> This patch implements the corresponding ingress actions
> TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.
>
> This allows attaching filters whose target is to hand matching skbs into
> the rx processing of a specified device.
>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Tested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
