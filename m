From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Additional 802.11 net stack code posted
Date: Thu, 3 Jun 2004 20:45:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040604034513.GD7537@jm.kir.nu>
References: <40BECAFC.7040405@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40BECAFC.7040405@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 03, 2004 at 02:53:48AM -0400, Jeff Garzik wrote:

> One of things that a proper "802.11 stack" should be is tie closely into 
> the core net stack, so that translation to/from 802.3 isn't going on all 
> the time.  One wants to create, receive, and "understand" native 802.11 
> frames, and provide a sane management infrastructure.

Yes, indeed. When working outside the kernel tree, it was somewhat
difficult to do this kind of changes, but this is certainly one of my
goals, too, and now would be a good time to get the implementation
together.

> To that end, I ask that wireless hackers please study stub 802.11 code 
> that DaveM wrote

Thanks! I will need to do some experimenting with this code, so this
will take some time. Based on the quick browse through the files, there
are number of things I have been missing before..

-- 
Jouni Malinen                                            PGP id EFC895FA
