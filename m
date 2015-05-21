From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ingress policying for realtime protocol
Date: Wed, 20 May 2015 19:32:30 -0700
Message-ID: <1432175550.4060.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150519211145.GA23134@pengutronix.de>
	 <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
	 <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7OJ8WUtPg7zah17DgkNFtcJznjnT0ys-qYN2c_Trm6S3A@mail.gmail.com>
	 <1432173180.4060.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7Pe6274a7ixbFpg+-dbxAwDXF=uKfSbxUf17Bbmuf_VDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33720 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbbEUCcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 22:32:33 -0400
Received: by pdbqa5 with SMTP id qa5so90704910pdb.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 19:32:32 -0700 (PDT)
In-Reply-To: <CAHA+R7Pe6274a7ixbFpg+-dbxAwDXF=uKfSbxUf17Bbmuf_VDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 18:59 -0700, Cong Wang wrote:
> On Wed, May 20, 2015 at 6:53 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Listen Cong, could you please stop assuming that I am a jerk ?
> 
> It is at least the second time to tell you: you SHOULD direct my email
> to /dev/null, SERIOUSLY, I have no interest to argue any stupid thing
> like this with you, PERIOD.
> 
> Since you use gmail, add a filter for both cwang@twopensource.com
> and xiyou.wangcong@gmail.com
> 
> HUGE thanks for doing it! It will me a lot of time!

No, I want to block you sending stuff without me having a chance to
comment.

Yeah, I am _that_ stupid.

In case you missed it, there was 'realtime protocol' in the thread
title.

ifb in ingress is adding jitter and nondeterministic behavior.

While a tc policer adds nothing but possibly some cpu cycles that can
easily be accounted for.

I gave a simple working script, because I am tired of people sending
'good advices' but do not care to send a working sample.
