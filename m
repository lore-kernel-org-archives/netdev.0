From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 2.6.0-test9-bk27-netdrvr-exp1 - r8169 update
Date: Mon, 24 Nov 2003 09:04:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124090421.A4482@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <3FC14058.4010600@mcve.com> <20031124004023.A1140@electric-eye.fr.zoreil.com> <3FC14AA3.9050009@mcve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad@mcve.com>
Content-Disposition: inline
In-Reply-To: <3FC14AA3.9050009@mcve.com>; from brad@mcve.com on Sun, Nov 23, 2003 at 07:02:43PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Brad House <brad@mcve.com> :
[...]
> The kernel locked hard on running a   dhcpcd eth0
> no panic output to the screen (I don't have a serial cable
> hooked up, or anything, so I don't know if it output anything
> there)

Well, thanks anyway.

> I'm sure the 'pile' of code left from realtek left will fix it
> though ;)

Just to be sure:
1) you are running x86-64;
2) vanilla 2.6.0-test9 does not work either.

If 2) if false I can/must search an error in the proposed changes.

--
Ueimor
