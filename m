From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Sun, 10 Sep 2017 16:03:38 +0200
Message-ID: <20170910140338.GA1860@nanopsycho>
References: <20170906111419.5115-1-jiri@resnulli.us>
 <20170907.191800.218886770521884093.davem@davemloft.net>
 <CAM_iQpXSjXWPw9QY7VHGnKssLHCBSJq4XnS2KPTheLB7_rBF7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jakub Kicinski <kubakici@wp.pl>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35773 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751756AbdIJODm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 10:03:42 -0400
Received: by mail-wr0-f193.google.com with SMTP id n64so3268903wrb.2
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 07:03:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpXSjXWPw9QY7VHGnKssLHCBSJq4XnS2KPTheLB7_rBF7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 09, 2017 at 08:46:42PM CEST, xiyou.wangcong@gmail.com wrote:
>On Thu, Sep 7, 2017 at 7:18 PM, David Miller <davem@davemloft.net> wrote:
>>
>> This doesn't apply cleanly any more, please respin.
>>
>
>Sigh, you applied this patch despite of strong objections from me.
>
>I seriously doubt your tastes now, David. Fine, this code does not
>deserve a good taste at all, let bugs stay there.

Actually, the reported bug is resolved by this patch. I like your
approach Cong, we can make it work and follow-up on this patch.
Please stay calm and be patient...
