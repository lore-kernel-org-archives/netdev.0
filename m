From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: patch: namsiz
Date: 16 Jan 2005 14:17:13 -0500
Message-ID: <1105903033.1097.829.camel@jzny.localdomain>
References: <1105900522.1090.798.camel@jzny.localdomain>
	 <41EAB74F.6060507@trash.net>  <20050116185630.GZ26856@postel.suug.ch>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050116185630.GZ26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On my part - theres one little change i made - just compiling it as we
speak;
I will post and stop there until you are done

cheers,
jamal

On Sun, 2005-01-16 at 13:56, Thomas Graf wrote:
> * Patrick McHardy <41EAB74F.6060507@trash.net> 2005-01-16 19:49
> > Jamal Hadi Salim wrote:
> > 
> > >heres one ive wanted to do for a while - dissociate action name size
> > >from ifnamsiz. for now set it to namize, but later may change it.
> > >
> > The same can be done for sch_api and cls_api. I'll add it to my tree
> > when I'm done with the current fixes, unfortunately one of them has
> > to touch basically all files in net/sched and I want to avoid clashes.
> 
> Go ahead, I have no changes in my tree except in a few header files
> and the necessary iproute2 changes will occupy me for a while.
> 
> 
