From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 09:37:33 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209280537.JAA03046@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0209280813030.8846-100000@netcore.fi>
Mime-Version: 1.0
Cc: davem@redhat.com, yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0209280813030.8846-100000@netcore.fi> from "Pekka Savola" at Sep 28, 2 08:24:58 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Or would you have an already-sorted list of possible candidate addresses 
> for each route in the order of preference?

I am not mad yet. :-)

What preference? You must select _one_ address, you do not need lost
candidates.


> And recalculate always when address changes?

What address? Interface address? Routing tables used to be synchronized
to this.


> This is IMO a wrong approach from user's perspective.  Perhaps not if the 
> algorithm was run and e.g. additional, temporary "address selection" 
> routes were created by kernel.
>  
> > > (stuff that's network prefix -independent
> > 
> > I am sorry, I feel I do not understand what you mean.
> 
> Hmm.. this depends on the interpretation of the concept above.  If the
> list is refreshed always when addresses change or change state, this could
> perhaps work..

I am afraid I do not understand what "address", "state", "temporary" routes
etc you mean. It remained in your brains. :-)

Pekka, are you not going to sleep? (I am.) I bet when you reread this tomorrow,
you will not blame that my brains eventually falled to "parse error" loop. :-)

Alexey
