From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 2.6.0-test9-bk27-netdrvr-exp1 - r8169 update
Date: Mon, 24 Nov 2003 18:49:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124184908.A9566@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <3FC14058.4010600@mcve.com> <20031124004023.A1140@electric-eye.fr.zoreil.com> <3FC14AA3.9050009@mcve.com> <20031124090421.A4482@electric-eye.fr.zoreil.com> <3FC21843.2080805@mcve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad@mcve.com>
Content-Disposition: inline
In-Reply-To: <3FC21843.2080805@mcve.com>; from brad@mcve.com on Mon, Nov 24, 2003 at 09:40:03AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Brad House <brad@mcve.com> :
[...]
> > 2) vanilla 2.6.0-test9 does not work either.
> 
> correct, but the system doesn't lock up with vanilla -test9,
> dhcpcd just hangs, then will eventually return.

I have fscked something then. Could you apply the patches in order to
figure which one triggers the lock-up ?

--
Ueimor
