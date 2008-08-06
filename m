From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [GIT]: Networking
Date: Wed, 6 Aug 2008 16:35:04 +0200
Message-ID: <200808061635.05292.IvDoorn@gmail.com>
References: <20080805.190020.244441681.davem@davemloft.net> <200808061022.02432.IvDoorn@gmail.com> <20080806131503.GD7036@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:28328 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbYHFOLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 10:11:03 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1138569nfc.21
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 07:09:59 -0700 (PDT)
In-Reply-To: <20080806131503.GD7036@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 August 2008, John W. Linville wrote:
> On Wed, Aug 06, 2008 at 10:22:02AM +0200, Ivo van Doorn wrote:
> > On Wednesday 06 August 2008, Linus Torvalds wrote:
> 
> > > Well, it's also trying to support both 2.4.x and 2.6 etc. Yeah, that is 
> > > horrid. At the same time, I can't say that the "rewrite it entirely" 
> > > approach of the previous-gen cards has worked very well either, since that 
> > > seems to have just perpetuated the problems. It would be great to try to 
> > > educate them, but I'm not finding even an email address in the sources.
> > 
> > I've send a mail to Ralink with a request if they could step away from the
> > "port the windows driver to linux" idea and get the Linux driver "kernel-ready"
> > early on.
> > That won't solve the problem now, but hopefully it does mean the drivers for
> > the next generation can go into the kernel sooner.
> 
> The Ralink guys are being educated and AFAICT they are interested in
> better participation.  Time will tell, of course.
> 
> In the meantime as Ivo indicated he is "on the case" -- I think we
> will see something before too long.

For the interested, the rt2800pci and rt2800usb code which I am working on can
be found in the experimental branch of my repository:
http://git.kernel.org/?p=linux/kernel/git/ivd/rt2x00.git;a=shortlog;h=experimental
Because the code is incomplete it cannot be tested, but it gives at least an idea
on what is already done. ;)

Ivo
