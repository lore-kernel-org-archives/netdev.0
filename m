From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: namsiz
Date: Sun, 16 Jan 2005 19:56:30 +0100
Message-ID: <20050116185630.GZ26856@postel.suug.ch>
References: <1105900522.1090.798.camel@jzny.localdomain> <41EAB74F.6060507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@znyx.com, "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41EAB74F.6060507@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41EAB74F.6060507@trash.net> 2005-01-16 19:49
> Jamal Hadi Salim wrote:
> 
> >heres one ive wanted to do for a while - dissociate action name size
> >from ifnamsiz. for now set it to namize, but later may change it.
> >
> The same can be done for sch_api and cls_api. I'll add it to my tree
> when I'm done with the current fixes, unfortunately one of them has
> to touch basically all files in net/sched and I want to avoid clashes.

Go ahead, I have no changes in my tree except in a few header files
and the necessary iproute2 changes will occupy me for a while.
