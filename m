From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 00/13] net_sched: misc cleanups and improvements
Date: Tue, 4 Nov 2014 17:25:31 -0800
Message-ID: <CAM_iQpXZBz=Ha2h3mCwnZKa3Etx7Ya9NxAWe_p8T+VjRUs5g0g@mail.gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
	<1415125250.25370.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:62927 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbaKEBZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 20:25:32 -0500
Received: by mail-oi0-f54.google.com with SMTP id a141so9744633oig.27
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 17:25:32 -0800 (PST)
In-Reply-To: <1415125250.25370.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 10:20 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> If you do not care of writing good changelogs and explain why you want
> all this, why should I care spending time to review all this stuff ?
>
> What is the plan, beyond all this code churn ?

Why $subject isn't obvious?

I don't understand why you are only mean to me (and probably David Taht too).

Sit down and search the history, you will find:

commit c6be2a10ac2f810bdd01e978c93a8ef65b46120b
Merge: 7fd2561 44cc8ed
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Oct 29 15:59:43 2014 -0400

    Merge branch 'xen-netback-next'

    David Vrabel says:

    ====================
    xen-netback: minor cleanups

    Two minor xen-netback cleanups originally from Zoltan.
    ====================

    Signed-off-by: David S. Miller <davem@davemloft.net>


Tell me, why this changelog in anyway could be better than me? which
was accepted (of course not by you). You can argue I have 13 patches,
but, there is no big difference between 13 cleanup's and 2 cleanup's,
cleanup's are cleanup's, that's it.

Seriously, think about why it should when it's just cleanup's, be practical.
