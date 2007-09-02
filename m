From: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 19:21:15 +0100
Message-ID: <20070902182115.GR21089@ftp.linux.org.uk>
References: <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <20070902113638.78fbd202@the-village.bc.nu> <Pine.LNX.4.64.0709021303001.4312@condmat1.ciencias.uniovi.es> <20070902115041.GM16016@stusta.de> <Pine.LNX.4.64.0709021416130.6181@condmat1.ciencias.uniovi.es> <20070902134612.28a88761@the-village.bc.nu> <Pine.LNX.4.64.0709021446550.6181@condmat1.ciencias.uniovi.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Constantine A. Murenin" <mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Igor Sobrado <igor-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709021446550.6181-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 02, 2007 at 03:00:46PM +0200, Igor Sobrado wrote:
> >Not strictly true. They can either agree to a change and issue one or
> >they can convey to other parties the right to change the terms. The GPL
> >for example does this for version selection.
> 
> So, under a dual-licensed BSD/GPL code the latter license allows a 
> developer to remove the GPL license itself and release a single-licensed 
> BSD code if other parties want to do it?

Exactly.  That's what dual-licensing is.

[quote]
This is no different from the fact that we have some drivers that are
GPLv2/BSD licensed. Within the kernel, they are GPLv2. But on their own, 
you can choose to use them under the BSD license, make your changes to
them, and release them commercially.
And correct - I cannot (and neither can anybody else) then accept those
*non*GPLv2 changes back.
[end quote]

That's from Linus and quite recently.

FWIW, it's damn hard to codify "... and changes to this code should not
change the situation".  It's certainly a very good policy and in this
case it's the only sane policy.

[quote]
Actually, normally I *do* have such a trust. It's why I have no problem
with drivers that are dual-GPL/BSD, and in fact, I've told people that I
don't want them to turn them into GPL-only, because that is simply not   
polite.
[end quote]

Same posting from Linus.  And that's much more relevant to shooting the patch
in question down (and IMO it ought to be shot down) than references to
legality.
