From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Sat, 18 Jan 2014 15:38:29 -0800
Message-ID: <CAM_iQpXd_MCiD26cCGzMzamK+Uz3jm5-LOns1Pud-1j2GYXhQw@mail.gmail.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
	<CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com>
	<52D97746.1040408@redhat.com>
	<CAM_iQpUoQcHpQJn-nYp9mO+XXMmXSjFxy3ASwchAH-qECoz9OA@mail.gmail.com>
	<1390065511.31367.535.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpV5NO5YZkQ3dSj_GYhNE2jUdwcYgbX1uNaFua71a266HQ@mail.gmail.com>
	<1390072047.31367.543.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35119 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbaARXia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 18:38:30 -0500
Received: by mail-ob0-f181.google.com with SMTP id va2so2221615obc.12
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 15:38:29 -0800 (PST)
In-Reply-To: <1390072047.31367.543.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc'ing netdev back...

On Sat, Jan 18, 2014 at 11:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Daniel did the right thing and David agreed.
>
> And I agreed.

If you mean the code, I don't even want to argue from the beginning.

If you mean the author of the patch, it is obviously wrong.

>
> So if you want to fight, feel free, but its going to be really hard.
>

I see.

Next time, I will pick up your patch, change a very minor issue,
and *steal* it as mine (a.k.a ignoring From:). So that in the changelog
your patch will become mine.

You don't mind, since you already agreed above...
