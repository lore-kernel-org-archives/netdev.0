From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/4] net: increase frag hash size
Date: Thu, 25 Apr 2013 15:11:14 -0400 (EDT)
Message-ID: <20130425.151114.821766164335312209.davem@davemloft.net>
References: <20130424154822.16883.93014.stgit@dragon>
	<51785827.1000007@cogentembedded.com>
	<1366884795.26911.510.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758063Ab3DYTLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 15:11:19 -0400
In-Reply-To: <1366884795.26911.510.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 25 Apr 2013 12:13:15 +0200

> Did you know that you can use the string "v3.8-rc3-503-gc2a9366" like:
>  git show v3.8-rc3-503-gc2a9366
> That's why I like this kind of commit ID better, as it also tell the
> reader what approx version this patch were in.

Don't invent your own conventions without discussing it with other
developers first.

Being different in style from what other people are doing hurts all
by itself, because people have to interpret and read your commit
messages differently.

> Dave, do you want me to resubmit this, with nitpicked commit message?

Of course.
