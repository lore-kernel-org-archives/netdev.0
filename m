From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats
	in	action	policer
Date: 20 Dec 2004 09:32:44 -0500
Message-ID: <1103553164.1050.365.camel@jzny.localdomain>
References: <20041215130128.GK8493@postel.suug.ch>
	 <1103119774.1077.74.camel@jzny.localdomain> <41C05B60.6030504@trash.net>
	 <1103484249.1046.143.camel@jzny.localdomain> <41C6A6CC.1050105@trash.net>
	 <20041220140325.GW17998@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041220140325.GW17998@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-20 at 09:03, Thomas Graf wrote:

> 
> Ifs and buts, it was solely and purely my fault. period.
> 

No fault on anyone - its a process of improving what we do.

> Agreed, the only bug which would have been easly found with the
> testframework was the CBQ slab corruption bug due deleting
> filters twice added with your generic filter deletion simplification.
> Unfortunately, I'm more error-prone than most so I need a testframework.

I need it to ;-> It will help me be less conservative ;->
Thomas, we need automation of these tests - I just relaized what you
have is not really in that category. Refer to sample example i posted.
Doesnt have to be exactly like that, but somewhere along those lines.

cheers,
jamal
