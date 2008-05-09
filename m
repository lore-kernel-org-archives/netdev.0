From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Fri, 09 May 2008 14:43:59 -0700 (PDT)
Message-ID: <20080509.144359.194792251.davem@davemloft.net>
References: <alpine.LFD.1.10.0805081848170.2940@woody.linux-foundation.org>
	<4824606E.3040409@garzik.org>
	<alpine.LFD.1.10.0805090805210.3142@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751840AbYEIVoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 17:44:04 -0400
In-Reply-To: <alpine.LFD.1.10.0805090805210.3142@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 9 May 2008 08:05:47 -0700 (PDT)

> On Fri, 9 May 2008, Jeff Garzik wrote:
> > 
> > The e1000e change is just a bunch of code additions for a new phy type, not a
> > bunch of /changes/ really.  Is that the change you're concerned with?
> 
> Yes. I saw 800 new lines to a driver I use, and I go "Ugh".

And if it enabled support for a device you have, for which you've been
patching the driver for some time, you'd go "Yippie!" :-)))

BTW, this reminds me, did we get that driver in for the device the
EEPC machines use?  I have this strange feeling like that slipped
through the cracks.

