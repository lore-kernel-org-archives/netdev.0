From: Nicolas Pitre <nico@cam.org>
Subject: Re: SMC91x: forcing speed
Date: Mon, 08 Jun 2009 21:08:49 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0906082100460.31536@xanadu.home>
References: <4A2D85D7.6050509@gmail.com>
 <20090608.144445.72867560.davem@davemloft.net>
 <alpine.LFD.2.00.0906081807410.31536@xanadu.home>
 <20090608.160658.58946145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: mfuzzey@gmail.com, richard.rojfors@endian.se,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:57985 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbZFIBIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 21:08:52 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KKY00GZJ5UPIK60@VL-MO-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Mon, 08 Jun 2009 21:08:49 -0400 (EDT)
In-reply-to: <20090608.160658.58946145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Jun 2009, David Miller wrote:

> From: Nicolas Pitre <nico@cam.org>
> Date: Mon, 08 Jun 2009 18:17:21 -0400 (EDT)
> 
> > Wouldn't it be possible to accommodate those people with a generic 
> > ethtool module that simply interpret some kernel cmdline parameters in a 
> > uniform and maintainable way to apply some settings during kernel boot?
> 
> And you could even write it and maintain it somewhere if you
> like for other embedded people to use. :-)
> 
> Once full featured, I'd be happy to include it.

I have no need for such a thing myself at the moment so I won't do it.

But at least you're open to the idea which is good, and now people with 
such a need have a hint.


Nicolas
