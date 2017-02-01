From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 0/2] net/sched: act_sample: Little fixes
Date: Wed, 1 Feb 2017 09:14:48 -0800
Message-ID: <CAM_iQpVVP_Wkec4dwqM=kUiF3kyrQuBgFNFRN_0bftsWBYbOtw@mail.gmail.com>
References: <1485855234-9941-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33920 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752903AbdBARPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:15:10 -0500
Received: by mail-wm0-f65.google.com with SMTP id c85so6985085wmi.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 09:15:09 -0800 (PST)
In-Reply-To: <1485855234-9941-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 1:33 AM, Yotam Gigi <yotamg@mellanox.com> wrote:
> Little fixes in sample tc action.
>
> Yotam Gigi (2):
>   net/sched: act_sample: Fix error path in init
>   net/sched: act_psample: Remove unnecessary ASSERT_RTNL
>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
