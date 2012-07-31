From: folkert <folkert@vanheusden.com>
Subject: Re: CPU: 0 Not tainted  (3.1.9+ #1) when ifconfig rose0 down
Date: Tue, 31 Jul 2012 19:58:43 +0200
Message-ID: <20120731175842.GA845@belle.intranet.vanheusden.com>
References: <5017E786.5000102@free.fr>
 <5017F96B.1060701@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@free.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5017F96B.1060701@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Here is a complementary observation.
> Trying to remove rose module with rmmod rose did not create any
> kernel panic.

A while ago I wrote a script that at random removed and inserted modules
into the system and that gave surprising results: not only crashing
system, also corrupt filesystems etc. Filed a bug-report and I was told
that removing a module might work but there's no guarantee.



Folkert van Heusden

-- 
Feeling generous? -> http://www.vanheusden.com/wishlist.php
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com
