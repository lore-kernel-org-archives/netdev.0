From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: [PATCH] Re: ifconfig up/down problem
Date: Tue, 9 Sep 2003 00:40:41 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.56.0309090039210.28325@space.comunit.de>
References: <Pine.LNX.4.56.0309090004100.24700@space.comunit.de>
 <3F5CFF7E.1090005@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
   Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F5CFF7E.1090005@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 8 Sep 2003, Jeff Garzik wrote:

> Sven-Haegar Koch wrote:
> > Short: ifconfig ethX down locks
> Does the attached patch fix it?

Yes, it does - thanks a lot!

c'ya
sven

-- 

The Internet treats censorship as a routing problem, and routes around it.
(John Gilmore on http://www.cygnus.com/~gnu/)
