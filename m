From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/13] net_sched: misc cleanups and improvements
Date: Thu, 06 Nov 2014 10:17:53 -0800
Message-ID: <1415297873.13896.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1415125250.25370.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpXZBz=Ha2h3mCwnZKa3Etx7Ya9NxAWe_p8T+VjRUs5g0g@mail.gmail.com>
	 <1415152068.1458.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpWw4UMKZcdZfpp5D-tDfj954fbptyXJUzydgFCero6xNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:60329 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaKFSR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 13:17:56 -0500
Received: by mail-ie0-f171.google.com with SMTP id x19so3530456ier.16
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 10:17:55 -0800 (PST)
In-Reply-To: <CAM_iQpWw4UMKZcdZfpp5D-tDfj954fbptyXJUzydgFCero6xNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-06 at 10:05 -0800, Cong Wang wrote:
> On Tue, Nov 4, 2014 at 5:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2014-11-04 at 17:25 -0800, Cong Wang wrote:
> >
> >> Seriously, think about why it should when it's just cleanup's, be practical.
> >
> > I seriously ask you to not do cleanups then.
> 
> Apparently you didn't say this when the following commits got accepted:

There is a difference from newbies and you.

As a community, we welcome new comers and encourage them,
but after a while, people sending mostly cleanups are shifting in a
category which doesn't fit to you.

We expect from you more interesting stuff. You can do it.

I understand you want to fully rewrite net/sched to your ideas of
how the code _should_ be.

Doing so forces other people already knowing all this code to spend time
to understand how things changed. And this is really not nice.

If you want to send cleanups, do this once in a while. Do not send 13
patches and expect us to be happy with that. We are not.
