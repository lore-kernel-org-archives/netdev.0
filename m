From: Brad House <brad@mcve.com>
Subject: Re: [PATCH] 2.6.0-test9-bk27-netdrvr-exp1 - r8169 update
Date: Mon, 24 Nov 2003 09:40:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC21843.2080805@mcve.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <3FC14058.4010600@mcve.com> <20031124004023.A1140@electric-eye.fr.zoreil.com> <3FC14AA3.9050009@mcve.com> <20031124090421.A4482@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031124090421.A4482@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Just to be sure:
> 1) you are running x86-64;

yep

> 2) vanilla 2.6.0-test9 does not work either.

correct, but the system doesn't lock up with vanilla -test9,
dhcpcd just hangs, then will eventually return.
