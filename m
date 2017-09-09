From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Sat, 9 Sep 2017 11:46:42 -0700
Message-ID: <CAM_iQpXSjXWPw9QY7VHGnKssLHCBSJq4XnS2KPTheLB7_rBF7g@mail.gmail.com>
References: <20170906111419.5115-1-jiri@resnulli.us> <20170907.191800.218886770521884093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jakub Kicinski <kubakici@wp.pl>, mlxsw@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33365 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdIISrD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 14:47:03 -0400
Received: by mail-pg0-f65.google.com with SMTP id i130so775802pgc.0
        for <netdev@vger.kernel.org>; Sat, 09 Sep 2017 11:47:02 -0700 (PDT)
In-Reply-To: <20170907.191800.218886770521884093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 7, 2017 at 7:18 PM, David Miller <davem@davemloft.net> wrote:
>
> This doesn't apply cleanly any more, please respin.
>

Sigh, you applied this patch despite of strong objections from me.

I seriously doubt your tastes now, David. Fine, this code does not
deserve a good taste at all, let bugs stay there.

Good luck!
