From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Mon, 26 May 2008 15:30:10 -0700 (PDT)
Message-ID: <20080526.153010.98925392.davem@davemloft.net>
References: <483B239D.4090402@krogh.cc>
	<20080526.151540.191673092.davem@davemloft.net>
	<483B37DB.707@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, matheos.worku@sun.com
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41781
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751049AbYEZWaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 18:30:15 -0400
In-Reply-To: <483B37DB.707@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Tue, 27 May 2008 00:21:15 +0200

> David Miller wrote:
> > From: Jesper Krogh <jesper@krogh.cc>
> > Date: Mon, 26 May 2008 22:54:53 +0200
> > 
> >> Applied and running.. I've now pushed 400GB of data through it trying to
> >> get it to hit the bug but it is still running.
> >>
> >> So without saying that it solved the problem, it definately seems so.
> >> 2.6.26-rc4 + above patch.
> > 
> > Thanks for testing.
> 
> I got this one:
> (also reported in the linux-2.6.26-rc4 thread)

That's for another driver.
