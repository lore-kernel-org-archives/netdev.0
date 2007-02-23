From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 0/2] myri10ge updates
Date: Fri, 23 Feb 2007 21:22:11 +0100
Message-ID: <45DF4CF3.20609@myri.com>
References: <45DC7B8C.9070501@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1969 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932650AbXBWUYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 15:24:37 -0500
In-Reply-To: <45DC7B8C.9070501@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Hi Jeff,
>
> No big change in myri10ge these days, mainly just a workaround for
> boards that were shipped with a bug in their firmware (patch #1, for
> 2.6.21).
>
> Since things are pretty calm here, I am also resending the Large Receive
> Offload patch for inclusion (patch #2, maybe only for 2.6.22?). I didn't
> hear of anybody working on a generic LRO for the core stack, while our
> driver performance suffered from missing LRO for several months already.
> The code has been intensively tested by multiple customers.
>
> Thanks,
> Brice
>   

I just got a last-minute copyright/license fix. I sent it as patch #3.
Please apply this one for 2.6.21.

thanks,
Brice

