From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Thu, 11 Jun 2009 17:03:52 -0700 (PDT)
Message-ID: <20090611.170352.156688524.davem@davemloft.net>
References: <4A30A884.9000508@gmail.com>
	<1244732090.2785.12.camel@achroite>
	<alpine.LFD.2.00.0906111159080.31536@xanadu.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, mfuzzey@gmail.com,
	netdev@vger.kernel.org
To: nico@cam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752310AbZFLADu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:03:50 -0400
In-Reply-To: <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Pitre <nico@cam.org>
Date: Thu, 11 Jun 2009 12:22:59 -0400 (EDT)

> I think this is a good example from the embedded world providing a
> clean solution to a recurring issue which would return again to
> quick hacks if the mainline reception is "use a cramfs" again.

Well initrd is the cleanest solution.

People don't want to do it because it requires some work, and there
always recurring passive-aggressive mentions of "space issues" which
frankly is totally bogus.  You can make this thing as tiny as you want
it to be.

If someone implemented it one time, then it could be shared by other
folks needing the same solution.

But I guess us upstream kernel folk just "don't understand."
