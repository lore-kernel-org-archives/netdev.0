From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Fri, 13 Dec 2013 13:51:16 +0100
Message-ID: <20131213125116.GA28103@unicorn.suse.cz>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
 <20131211231236.GA8953@lion.mk-sys.cz>
 <20131212012115.GE4675@order.stressinduktion.org>
 <20131212091004.GA10703@unicorn.suse.cz>
 <20131212190810.GI4675@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39006 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602Ab3LMMvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 07:51:19 -0500
Content-Disposition: inline
In-Reply-To: <20131212190810.GI4675@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 08:08:10PM +0100, Hannes Frederic Sowa wrote:
> On Thu, Dec 12, 2013 at 10:10:05AM +0100, Michal Kubecek wrote:
> > 
> > On the other hand, the fix could be worth backporting to 3.4 stable
> > (more general, pre-3.6 stable branches) as the problem is much more
> > severe there.
> 
> Could you give it a try? I am not so sure if it really helps, maybe only in
> cases where more than one router is available.

I'll send a backport next week so that there is enough time for a review
before the original patch gets into mainline.

                                                          Michal Kubecek
