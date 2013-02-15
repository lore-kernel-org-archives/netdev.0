From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: fix infinite loop in __skb_recv_datagram()
Date: Fri, 15 Feb 2013 18:55:22 +0100
Message-ID: <20130215175522.GC20018@order.stressinduktion.org>
References: <1360638903.20362.32.camel@edumazet-glaptop> <CA+ydwtoBttwiVz+oy0hnetUTQMi7XHyS9bfGzjuP1L41srBk=g@mail.gmail.com> <1360685813.13993.12.camel@edumazet-glaptop> <20130212.160733.2235089567079483883.davem@davemloft.net> <20130215124141.GB20018@order.stressinduktion.org> <1360950210.3192.0.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	tt.rantala@gmail.com, netdev@vger.kernel.org, davej@redhat.com,
	xemul@parallels.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37764 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869Ab3BORzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 12:55:24 -0500
Content-Disposition: inline
In-Reply-To: <1360950210.3192.0.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 05:43:30PM +0000, Ben Hutchings wrote:
> David has already worked that out for himself:
> http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

Thanks, didn't know where to look.
