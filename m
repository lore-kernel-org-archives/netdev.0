From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Thu, 11 Jun 2009 16:24:05 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0906111605060.31536@xanadu.home>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
 <1244732090.2785.12.camel@achroite>
 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
 <1244739166.2785.52.camel@achroite>
 <alpine.LFD.2.00.0906111333100.31536@xanadu.home>
 <1244744967.2785.61.camel@achroite>
 <alpine.LFD.2.00.0906111452340.31536@xanadu.home>
 <1244748719.2785.72.camel@achroite>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: mfuzzey@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:26825 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926AbZFKUYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 16:24:24 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR001.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KL300LE6CO64SP0@VL-MH-MR001.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 11 Jun 2009 16:24:06 -0400 (EDT)
In-reply-to: <1244748719.2785.72.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009, Ben Hutchings wrote:

> On Thu, 2009-06-11 at 15:08 -0400, Nicolas Pitre wrote:
> [...]
> > > Please note, I'm talking about an init script -
> > > which you surely must have - not an initramfs, which I recognise is
> > > optional and unnecessary for most embedded systems.
> > 
> > An init script is already a luxury for some systems.
> 
> And so is an Ethernet port.  Instead of talking about hypotheticals, why
> not talk about the system you need this workaround for?

Look, I personally do not need this.  And I'm rather tired arguing with 
you.  Your shortsightedness and refusal for accommodation about needs 
that aren't yours is representative of the main reason why there is 
still a disconnect between mainline people and embedded people.  If you 
can't admit it then I've failed my attempt at bridging the gap.

The issue was discussed, people objected to driver kirks already, then I 
proposed this solution to which Davem agreed if it was done cleanly and 
maintained. And here it is under the form of an actual patch. So far 
you're the only one who just can't accept that compromise.  If your 
opposition -- which so far has nothing to do with the actual 
implementation but rather on the principle -- is not overruled by others 
then the embedded disconnect, of which this is only a tiny part of, has 
no hope of ever vanishing.

Have a good day.


Nicolas
