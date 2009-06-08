From: David Miller <davem@davemloft.net>
Subject: Re: SMC91x: forcing speed
Date: Mon, 08 Jun 2009 16:06:58 -0700 (PDT)
Message-ID: <20090608.160658.58946145.davem@davemloft.net>
References: <4A2D85D7.6050509@gmail.com>
	<20090608.144445.72867560.davem@davemloft.net>
	<alpine.LFD.2.00.0906081807410.31536@xanadu.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mfuzzey@gmail.com, richard.rojfors@endian.se,
	netdev@vger.kernel.org
To: nico@cam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756279AbZFHXG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 19:06:56 -0400
In-Reply-To: <alpine.LFD.2.00.0906081807410.31536@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Pitre <nico@cam.org>
Date: Mon, 08 Jun 2009 18:17:21 -0400 (EDT)

> Wouldn't it be possible to accommodate those people with a generic 
> ethtool module that simply interpret some kernel cmdline parameters in a 
> uniform and maintainable way to apply some settings during kernel boot?

And you could even write it and maintain it somewhere if you
like for other embedded people to use. :-)

Once full featured, I'd be happy to include it.

