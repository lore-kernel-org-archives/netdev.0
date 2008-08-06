From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [GIT]: Networking
Date: Wed, 6 Aug 2008 09:15:03 -0400
Message-ID: <20080806131503.GD7036@tuxdriver.com>
References: <20080805.190020.244441681.davem@davemloft.net> <A0AAD67C-1F54-4D85-A413-91BBBE044452@holtmann.org> <alpine.LFD.1.10.0808052308080.15995@nehalem.linux-foundation.org> <200808061022.02432.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756466AbYHFNcz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200808061022.02432.IvDoorn@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 06, 2008 at 10:22:02AM +0200, Ivo van Doorn wrote:
> On Wednesday 06 August 2008, Linus Torvalds wrote:

> > Well, it's also trying to support both 2.4.x and 2.6 etc. Yeah, that is 
> > horrid. At the same time, I can't say that the "rewrite it entirely" 
> > approach of the previous-gen cards has worked very well either, since that 
> > seems to have just perpetuated the problems. It would be great to try to 
> > educate them, but I'm not finding even an email address in the sources.
> 
> I've send a mail to Ralink with a request if they could step away from the
> "port the windows driver to linux" idea and get the Linux driver "kernel-ready"
> early on.
> That won't solve the problem now, but hopefully it does mean the drivers for
> the next generation can go into the kernel sooner.

The Ralink guys are being educated and AFAICT they are interested in
better participation.  Time will tell, of course.

In the meantime as Ivo indicated he is "on the case" -- I think we
will see something before too long.

John
-- 
John W. Linville
linville@tuxdriver.com
