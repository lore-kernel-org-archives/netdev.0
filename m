From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 0/6] 6lowpan: udp compression/uncompression fix
Date: Fri, 15 Nov 2013 06:12:32 +0100
Message-ID: <20131115051232.GA6744@omega>
References: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
 <1384445983.28716.1.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131114.170620.830861106940917404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, alex.bluesman.smirnov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	jukka.rissanen@linux.intel.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:62568 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab3KOFMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 00:12:39 -0500
Received: by mail-bk0-f54.google.com with SMTP id 6so1467181bkj.13
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 21:12:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131114.170620.830861106940917404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 05:06:20PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 14 Nov 2013 08:19:43 -0800
> 
> > On Thu, 2013-11-14 at 16:48 +0100, Alexander Aring wrote:
> >> The current 6LoWPAN udp compression/uncompression is completely broken.
> >> This patch series fix a lot of udp compression/uncompression issues and
> >> add support parsing with lowpan_fetch_skb function.
> > 
> > If its broken, why targeting net-next tree (which is closed BTW ATM) ?
> 
> In any event, if you do want it to go into net-next, please resubmit
> this series when the net-next tree opens back up after the merge
> window.
> 
ahh, didn't notice that. I will resubmit this series after merge window.
Thanks for this hint. :-)

Sorry for the noise.

- Alex
