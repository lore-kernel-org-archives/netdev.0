From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 28 Dec 2004 08:20:53 -0500
Message-ID: <1104240053.1100.53.camel@jzny.localdomain>
References: <200412270715.iBR7Fffe026855@hera.kernel.org>
	 <20041227121658.GI7884@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041227121658.GI7884@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-27 at 07:16, Thomas Graf wrote:
> > ChangeSet 1.2055.37.1, 2004/11/17 16:08:01-08:00, util@deuroconsult.ro
> > 
> > 	[PKT_SCHED]: Allow using nfmark as key in U32 classifier.
> > 	
> > 	Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
> > 	Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> I must have missed this one. This should have been implemented in the
> metadata action module to make it available to all classifiers.

You mean meta match. 

>  We
> should really stop to add more stuff to specific classifiers which have
> to be removed once we have metamatch. I've made a proposal on paper
> just need some more time to cook up a patch.

I have cycles now. Are you working on this or should i invest some of my
cycles in it? Lets fix this once and for all.

cheers,
jamal 
