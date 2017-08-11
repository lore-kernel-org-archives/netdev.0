From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/sched/hfsc: allocate tcf block for hfsc root class
Date: Fri, 11 Aug 2017 13:29:26 -0700
Message-ID: <CAM_iQpVGamTq7rUGKQDt3CREYPg1MZUeXWTMO1OdCZbi2SQWVw@mail.gmail.com>
References: <150235750037.493227.16245118631720190134.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33226 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753363AbdHKU3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:29:47 -0400
Received: by mail-pf0-f173.google.com with SMTP id h68so19958817pfk.0
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 13:29:47 -0700 (PDT)
In-Reply-To: <150235750037.493227.16245118631720190134.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 2:31 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> Without this filters cannot be attached.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")

Looks good.

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
