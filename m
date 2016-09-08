From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V6 0/4] net/sched: ip tunnel metadata
 set/release/classify by using TC
Date: Thu, 8 Sep 2016 08:44:28 +0300
Message-ID: <CAJL1qvF5gCoDhnhoVjrREnYQpoaUQ8r24-3O8dqBN+hHr7LtfQ@mail.gmail.com>
References: <1473235686-18975-1-git-send-email-hadarh@mellanox.com> <20160907.173246.209901227236135350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36665 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755574AbcIHGiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 02:38:25 -0400
Received: by mail-oi0-f52.google.com with SMTP id x125so3141058oia.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 23:38:25 -0700 (PDT)
In-Reply-To: <20160907.173246.209901227236135350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 3:32 AM, David Miller <davem@davemloft.net> wrote:
> From: Hadar Hen Zion <hadarh@mellanox.com>
> Date: Wed,  7 Sep 2016 11:08:02 +0300
>
>> This patchset introduces ip tunnel manipulation support using the TC subsystem.
>
> Please address the feedback given by Eric Dumazet for patch #4,
> thank you.

Sure, I'll fix it and re-send.

Thanks,
Hadar
