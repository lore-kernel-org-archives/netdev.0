From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 6 Sep 2016 09:54:28 -0400
Message-ID: <c25b04dc-cdf7-a13b-3275-a48866aa6806@mojatatu.com>
References: <1473169060-29651-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        alexei.starovoitov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f169.google.com ([209.85.213.169]:34381 "EHLO
        mail-yb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933689AbcIFNya (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 09:54:30 -0400
Received: by mail-yb0-f169.google.com with SMTP id x93so81310454ybh.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 06:54:30 -0700 (PDT)
In-Reply-To: <1473169060-29651-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-06 09:37 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This action is intended to be an upgrade from a usability perspective
> from pedit (as well as operational debugability).
> Compare this:
>

Dave,
I will have to send some new version of this action - so please
dont apply.
As it stands right now, the per-cpu stats dont work; so code uses
global stats (which works).
Hoping to get some clarity from other people then some more testing.

cheers,
jamal
