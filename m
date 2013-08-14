From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/6] 6lowpan: introduce lowpan_fetch_skb function
Date: Wed, 14 Aug 2013 14:47:54 +0200
Message-ID: <20130814124754.GA2723@order.stressinduktion.org>
References: <1376478108-3539-1-git-send-email-alex.aring@gmail.com> <1376478108-3539-4-git-send-email-alex.aring@gmail.com> <20130814114921.GC2010@order.stressinduktion.org> <520B7029.3070903@gmail.com> <20130814124545.GB4303@x61s.8.8.8.8>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51160 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164Ab3HNMrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 08:47:55 -0400
Content-Disposition: inline
In-Reply-To: <20130814124545.GB4303@x61s.8.8.8.8>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 02:45:47PM +0200, Alexander Aring wrote:
> This was the old behaviour, we decide it to make it like this:
> 
> fail = ...
> fail |= ....
> 
> if (fail)
> 	...
> 
> We discussed that already at the linux-zigbee-devel mailinglist.
> I don't know what I should do now, on linux-zigbee-devel we decide it to
> this way, now we decide it in a other way...

Oh, I didn't know. Please just take my mail as a suggestion. If there
already was a discussion and you had a consensus about that please just
ignore my mails. :)

Thanks,

  Hannes
