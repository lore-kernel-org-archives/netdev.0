From: Jason Lunz <lunz@falooley.org>
Subject: Re: incorrect usage of UTS_RELEASE in bcm43xx_get_drvinfo
Date: Fri, 21 Jul 2006 16:05:09 -0400
Message-ID: <20060721200509.GB15478@knob.reflex>
References: <20060721185945.GA7611@suse.de> <200607212103.23954.mb@bu3sch.de> <20060721191329.GA15478@knob.reflex> <200607212127.23786.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Hering <olh@suse.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.reflexsecurity.com ([72.54.64.74]:33712 "EHLO
	crown.reflexsecurity.com") by vger.kernel.org with ESMTP
	id S1751150AbWGUUFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 16:05:13 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200607212127.23786.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2006 at 09:27:23PM +0200, Michael Buesch wrote:
> What is a major change? Why only on major change? Why not on
> simple changes, too? Simple changes sometimes introduce bugs, too.

the version number has whatever meaning you choose to assign to it.
Including none, if you so choose.

> What I wanted to say: I _never_ had debugging-problems, because
> I did not know the source state it was compiled from.

fair enough. The version field certainly doesn't seem to get much use in
other net drivers.

Jason
