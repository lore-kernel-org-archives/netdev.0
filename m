From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Thu, 25 Sep 2014 08:48:52 -0400
Message-ID: <54240F34.1050707@mojatatu.com>
References: <20140924160932.9721.56450.stgit@localhost>	<20140924161047.9721.43080.stgit@localhost>	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>	<20140924195831.6fb91051@redhat.com>	<54234225.5000503@mojatatu.com> <20140925102505.494acab1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	therbert@google.com, "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>, toke@toke.dk,
	Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:50421 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbaIYMtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 08:49:00 -0400
Received: by mail-ig0-f179.google.com with SMTP id l13so8313790iga.6
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 05:48:59 -0700 (PDT)
In-Reply-To: <20140925102505.494acab1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/14 04:25, Jesper Dangaard Brouer wrote:
> On Wed, 24 Sep 2014 18:13:57 -0400

> I've done measurements with netperf-wrapper:
>   http://netoptimizer.blogspot.dk/2014/09/mini-tutorial-for-netperf-wrapper-setup.html
>
> I have already previously posted my measurements here:
>   http://people.netfilter.org/hawk/qdisc/
>   http://people.netfilter.org/hawk/qdisc/measure01/
>   http://people.netfilter.org/hawk/qdisc/experiment01/
>

Theres a lot of data there to digest; all good looking.
I will try to pay attention to detail and get back to you.
What you have on those urls is fit for a paper, but what someone
like me (with ADD) needs is a summary somewhere maybe in the commit
logs.

> Please, see my previous mail where I described each graph.
>

Is this patch 0?
I think a simple statement in the commit log that no cats
were harmed ^W^W^W performance was affected. A paragraph
at most but if you want to do more, DaveM actually has no
problems if you write the details of a novel in patch 0.

cheers,
jamal
