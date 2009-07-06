From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Mon, 6 Jul 2009 18:31:06 +0200
Message-ID: <20090706163106.GA4559@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <a5d9929e0907052153x2db851bcj26f1433c716c8a90@mail.gmail.com> <20090706141916.GA3477@ami.dom.local> <200907061813.29379.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:35950 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbZGFQbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 12:31:11 -0400
Content-Disposition: inline
In-Reply-To: <200907061813.29379.andres@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 06:13:29PM +0200, Andres Freund wrote:
...
> > > Btw, I ran netem with delay for more than 48h on around 80mbit... That
> > > does  not exclude such a rarely triggered race, but makes it a bit more
> > > unlikely. (With migration thats around 3sec or so)
...
> Sorry once more.

Andres, the bisection + the above - you did 'the whole lotta work' and
you shouldn't be sorry at all! ;-)

Thanks again,
Jarek P.
