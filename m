From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Thu, 12 Dec 2013 20:08:10 +0100
Message-ID: <20131212190810.GI4675@order.stressinduktion.org>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com> <20131211231236.GA8953@lion.mk-sys.cz> <20131212012115.GE4675@order.stressinduktion.org> <20131212091004.GA10703@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51397 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab3LLTIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 14:08:11 -0500
Content-Disposition: inline
In-Reply-To: <20131212091004.GA10703@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 10:10:05AM +0100, Michal Kubecek wrote:
> On Thu, Dec 12, 2013 at 02:21:15AM +0100, Hannes Frederic Sowa wrote:
> > 
> > Yeah, I think your analysis is correct. Also you can see that (at least) I did
> > not considered this worth for -stable but only for net-next. ;)
> 
> On the other hand, the fix could be worth backporting to 3.4 stable
> (more general, pre-3.6 stable branches) as the problem is much more
> severe there.

Could you give it a try? I am not so sure if it really helps, maybe only in
cases where more than one router is available.

Greetings,

  Hannes
