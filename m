From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 3/6] 6lowpan: introduce lowpan_fetch_skb function
Date: Wed, 14 Aug 2013 14:54:18 +0200
Message-ID: <20130814125417.GA6815@x61s.8.8.8.8>
References: <1376478108-3539-1-git-send-email-alex.aring@gmail.com>
 <1376478108-3539-4-git-send-email-alex.aring@gmail.com>
 <20130814114921.GC2010@order.stressinduktion.org>
 <520B7029.3070903@gmail.com>
 <20130814124545.GB4303@x61s.8.8.8.8>
 <20130814124754.GA2723@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:46688 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932315Ab3HNMub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 08:50:31 -0400
Received: by mail-ea0-f172.google.com with SMTP id r16so4780241ead.17
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 05:50:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130814124754.GA2723@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

On Wed, Aug 14, 2013 at 02:47:54PM +0200, Hannes Frederic Sowa wrote:
> On Wed, Aug 14, 2013 at 02:45:47PM +0200, Alexander Aring wrote:
> > This was the old behaviour, we decide it to make it like this:
> > 
> > fail = ...
> > fail |= ....
> > 
> > if (fail)
> > 	...
> > 
> > We discussed that already at the linux-zigbee-devel mailinglist.
> > I don't know what I should do now, on linux-zigbee-devel we decide it to
> > this way, now we decide it in a other way...
> 
> Oh, I didn't know. Please just take my mail as a suggestion. If there
> already was a discussion and you had a consensus about that please just
> ignore my mails. :)
>
This discussion was only with two persons.
So I am happy to hear some other opinions. :-)

Regards
Alex
