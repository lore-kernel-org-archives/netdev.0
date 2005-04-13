From: Horms <horms@verge.net.au>
Subject: Re: [PATCH] Maintainers list update: linux-net -> netdev
Date: Wed, 13 Apr 2005 11:14:02 +0900
Message-ID: <20050413021400.GA1835@verge.net.au>
References: <20050412062027.GA1614@verge.net.au> <425C1E30.5060405@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>,
        Pavel Machek <pavel@ucw.cz>, Jeff Garzik <jgarzik@pobox.com>,
        Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
        schwidefsky@de.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: George Anzinger <george@mvista.com>
Content-Disposition: inline
In-Reply-To: <425C1E30.5060405@mvista.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2005 at 12:14:56PM -0700, George Anzinger wrote:
> Horms wrote:
> >
> >Use netdev as the mailing list contact instead of the mostly dead
> >linux-net list.
> >
> ~
> > PHRAM MTD DRIVER
> >@@ -1795,7 +1795,7 @@
> > POSIX CLOCKS and TIMERS
> > P:	George Anzinger
> > M:	george@mvista.com
> >-L:	linux-net@vger.kernel.org
> >+L:	netdev@oss.sgi.com
> > S:	Supported
> > 
> I don't really know about the rest of them, but I think this should be:
> L: linux-kernel@vger.kernel.org
> 
> Least wise that is where I look...

Yes, I was wondering about that one. Here is a patch that
adds to my previous patch. Trivial to say the least. 
I can re-diff the whole thing if that is more convenient.

-- 
Horms

POSIX CLOCKS and TIMERS disscussion is more appropriate
on linux-kernel than linux-net. As suggested by the maintainer,
George Anzinger.

Signed-off-by: Horms <horms@verge.net.au>

--- a/MAINTAINERS	2005-04-13 11:06:39.000000000 +0900
+++ b/MAINTAINERS	2005-04-13 11:07:04.000000000 +0900
@@ -1795,7 +1795,7 @@
 POSIX CLOCKS and TIMERS
 P:	George Anzinger
 M:	george@mvista.com
-L:	linux-net@vger.kernel.org
+L:	linux-kernel@vger.kernel.org
 S:	Supported
 
 PNP SUPPORT
