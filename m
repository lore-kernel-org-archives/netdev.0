From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: Mon, 20 Dec 2004 21:07:39 +0100
Message-ID: <20041220200739.GX17998@postel.suug.ch>
References: <20041219203050.GK17998@postel.suug.ch> <41C68CEF.3030803@trash.net> <1103552215.1048.333.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103552215.1048.333.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1103552215.1048.333.camel@jzny.localdomain> 2004-12-20 09:16
> Hehe. I am sure thats a cutnpaste(LinuxWay) from some code in the kernel
> probably sch_api.c (or maybe the code it was cutnpasted has been fixed
> in the last 3 years ;->).
> That needs fixing. Who is sending the patch?

I'll put it into my patchset so it gets into the test cycles.

> Its not that expensive since done on config path. But agree when proper
> codes exist its not needed.

It might cause random data to be printed onto the console ;) I'll
remove it in my patchset.
