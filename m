From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Tue, 30 Sep 2014 15:15:10 -0700
Message-ID: <1412115310.16704.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140930085114.24043.81310.stgit@dragon>
	 <1412077736.30721.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141001000752.4e553919@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:49510 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbaI3WPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 18:15:11 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so6848926pdb.35
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 15:15:11 -0700 (PDT)
In-Reply-To: <20141001000752.4e553919@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-01 at 00:07 +0200, Jesper Dangaard Brouer wrote:
> On Tue, 30 Sep 2014 04:48:56 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>  
> > In my opinion, you guys missed some opportunities :
> 
> This is a conservative first approach.  The merge window is approaching
> fast, is is annoying you are blocking a save conservative approach.

I am not blocking at all.

I am only disappointed V5 is no different from V4.

I will shut up then since it seems I am blocking things, or so you
believe.
