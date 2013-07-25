From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: minimum ICMPv6 message size vs. RPL's DIS
Date: Thu, 25 Jul 2013 15:58:20 +0200
Message-ID: <20130725135820.GB11592@order.stressinduktion.org>
References: <20130724232852.GA29572@ws> <20130725061731.GA12365@order.stressinduktion.org> <20130725103048.GB29572@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:39125 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab3GYN6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:58:21 -0400
Content-Disposition: inline
In-Reply-To: <20130725103048.GB29572@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 07:30:49AM -0300, Werner Almesberger wrote:
> Hannes Frederic Sowa wrote:
> > Hmm, maybe we should update the icmp header to something like
> 
> That would be quite clean. Is it okay to introduce new names
> like that in a uapi/ header (uapi/linux/icmpv6.h) ?

I would say no problem. But as I just realized that it could be a bit
problematic because the new defines have actually pretty common names,
let's cc David Miller. Perhaps he has an advice?

Greetings,

  Hannes
