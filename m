From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 4/5] Net: ath5k, license is GPLv2
Date: Thu, 30 Aug 2007 15:45:06 +0200
Message-ID: <20070830134506.GB2778@ff.dom.local>
References: <20070829204529.66ce1bcb@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jirislaby@gmail.com>, linville@tuxdriver.com,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Xavier Bestel <xavier.bestel@free.fr>,
	Jiri Slaby <jirislaby@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:38691 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754057AbXH3Nnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 09:43:45 -0400
Content-Disposition: inline
In-Reply-To: <20070829204529.66ce1bcb@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30-08-2007 13:59, Johannes Berg wrote:
> On Wed, 2007-08-29 at 15:13 +0200, Xavier Bestel wrote:
> 
>> How about asking for changes to be dual-licenced too ?
> 
> In theory, that could work, but in practice relying on functions that
> the Linux kernel offers in GPLv2-only headers etc. will make the result
> GPLv2 anyway, and disentangling it would be a nightmare.
> 

Why?

Very good point, but, in my opinion, it should be still resonable for
both sides: it simply means such changes are mostly unusable for the
other side, but nobody is going to waste time for marking all these
places, or care about suing if accidentally the changes, after some
adaptation, are usable for the other side. Unless you think or know
that "#include xyz" or "print_linux_way()" should add more than these
(maybe unusable) words or lines only?

Jarek P.
