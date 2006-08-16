From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Wed, 16 Aug 2006 08:08:57 -0400
Message-ID: <1155730137.5122.99.camel@jzny2>
References: <20060815122300.GV14627@postel.suug.ch>
	 <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
	 <20060816105856.GW14627@postel.suug.ch>
	 <20060816111240.GA28846@gondor.apana.org.au>
	 <20060816114003.GY14627@postel.suug.ch>
	 <20060816115747.GA29440@gondor.apana.org.au>
	 <20060816120559.GZ14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, hasso@estpak.ee,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:13731 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751137AbWHPMJE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 08:09:04 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GDKCp-0002Ly-5c
	for netdev@vger.kernel.org; Wed, 16 Aug 2006 08:09:07 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060816120559.GZ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2006-16-08 at 14:05 +0200, Thomas Graf wrote:

> Right, but he forgot the bits in IPv6 which I now fixed. The
> changeset introducing those current->pid uses was definitely
> simply wrong. I'm not questioning that :)

Herbert, if you look at the thread as well I am no longer questioning
that either ;->

cheers,
jamal

PS:- Would a topic of "things i wish netlink did better" be of interest
for discussion (maybe for netconf)? (Un)fortunately, we are fixing some
of them with genetlink;-> 

