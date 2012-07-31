From: folkert <folkert@vanheusden.com>
Subject: Re: CPU: 0 Not tainted  (3.1.9+ #1) when ifconfig rose0 down
Date: Tue, 31 Jul 2012 19:56:42 +0200
Message-ID: <20120731175641.GE7638@belle.intranet.vanheusden.com>
References: <5017E786.5000102@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@free.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5017E786.5000102@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I observe systematically a kernel panic when I try to shutdown rose0
> device using ifconfig rose0 down

That's funny: I always get a kernel panic(!) when doing an ifconfig
rose0 up!


Folkert van Heusden

-- 
Nagios user? Check out CoffeeSaint - the versatile Nagios status
viewer! http://www.vanheusden.com/java/CoffeeSaint/
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com
