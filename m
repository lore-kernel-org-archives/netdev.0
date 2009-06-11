From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
	configuration.
Date: Thu, 11 Jun 2009 21:48:16 +0100
Message-ID: <1244753296.2785.95.camel@achroite>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
	 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
	 <1244732090.2785.12.camel@achroite>
	 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
	 <1244739166.2785.52.camel@achroite>
	 <alpine.LFD.2.00.0906111333100.31536@xanadu.home>
	 <1244744967.2785.61.camel@achroite>
	 <alpine.LFD.2.00.0906111452340.31536@xanadu.home>
	 <1244748719.2785.72.camel@achroite>
	 <alpine.LFD.2.00.0906111605060.31536@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mfuzzey@gmail.com, netdev@vger.kernel.org
To: Nicolas Pitre <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:41903 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751749AbZFKUsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 16:48:18 -0400
In-Reply-To: <alpine.LFD.2.00.0906111605060.31536@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-06-11 at 16:24 -0400, Nicolas Pitre wrote:
> On Thu, 11 Jun 2009, Ben Hutchings wrote:
> 
> > On Thu, 2009-06-11 at 15:08 -0400, Nicolas Pitre wrote:
> > [...]
> > > > Please note, I'm talking about an init script -
> > > > which you surely must have - not an initramfs, which I recognise is
> > > > optional and unnecessary for most embedded systems.
> > > 
> > > An init script is already a luxury for some systems.
> > 
> > And so is an Ethernet port.  Instead of talking about hypotheticals, why
> > not talk about the system you need this workaround for?
> 
> Look, I personally do not need this.  And I'm rather tired arguing with 
> you.  Your shortsightedness and refusal for accommodation about needs 
> that aren't yours is representative of the main reason why there is 
> still a disconnect between mainline people and embedded people.  If you 
> can't admit it then I've failed my attempt at bridging the gap.
[...]

It's not my call as to whether your needs are accommodated, and in any
case I'm not trying to dismiss them.  I'm trying to understand them and
to suggest what seems like a better solution.

I'm primarily a driver maintainer and I work with an out-of-tree module
as well as an in-tree driver.  I've had to deal with many objections in
the process of submitting that out-of-tree code, and I worked to
overcome them.  This took several iterations and it was quite
frustrating at times.  But the result was a better driver.

I don't want to spend time arguing either, so if I've not yet convinced
you to try an alternative then so be it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

