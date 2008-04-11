From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 18:35:37 +0400
Message-ID: <20080411143537.GA27874@2ka.mipt.ru>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net> <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net> <47FEBDAA.7010305@rtr.ca> <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi> <47FF6555.50004@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	tilman@imap.cc, yoshfuji@linux-ipv6.org,
	Jeff Garzik <jeff@garzik.org>, rjw@sisk.pl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41823 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758488AbYDKOgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 10:36:36 -0400
Content-Disposition: inline
In-Reply-To: <47FF6555.50004@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 09:19:17AM -0400, Mark Lord (lkml@rtr.ca) wrote:
> >>Or I can ignore it, like the net developers, since I have a workaround.
> >>And then we'll see what other apps are broken upon 2.6.25 final release.
> 
> That's not demanding, that's quite relaxed.  I had a good workaround,
> and didn't really care any more at that point.  Just though it was rather
> odd that none of the developers seemed interested in tracking it down.
> I offered tons of help, gave it, and said I didn't have time for a full
> bisect at that juncture.
> 
> For that, I get repeatedly slammed by the netdev folks.
> Even after I put aside *paid* work to submit to your demands.
> 
> Next time around, I won't bother reporting bugs to you folks,
> that's for damned sure.

Actually that will be the best decision from evolutional point of view. 

Bugs, which 'are thrown back to your face' like what you did with this
one, are useless. Developers already know, that bugs exist. 

If you do not care about bug, why do you ever bothered filling it?
You expected that anyone will start running to fix it for you.
You were wrong. Developers only fix bugs, which do not require
mind-reading and magnetic quantification of your brain.

If you do not want to help fixing it, do not expect it will be fixed at
all. Sentence, that you will probably understand better: no one get paid
to fix it.

No one get fun fixing something with description you provided
(not sure about David though, probably he has some masochistic
propensities doing that and trying to get some bits of information
from reportes for years).
You were suggested some simple checks, they did not help.
Developers can not remotely control electrons in your wires, so next
sugestion was bisecting, which ended up with some crap from your point.

If you want bug got fixed, provide info and if it is not enough, help by
trying what you are being suggested, if you do not want, stop.

-- 
	Evgeniy Polyakov
