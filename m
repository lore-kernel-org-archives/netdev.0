From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: generic 802.11 stack
Date: Tue, 14 Sep 2004 23:02:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915030211.GK7839@ruslug.rutgers.edu>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <4145352F.4040807@pobox.com> <20040913162153.33ff37ec.davem@davemloft.net> <200409140819.25787.vkondra@mail.ru> <20040913223500.66c06cde.davem@davemloft.net> <20040914235512.GJ7839@ruslug.rutgers.edu> <414788A4.7070003@pobox.com> <41479228.8080507@atheros.com> <4147989C.7030708@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greg chesson <greg@atheros.com>,
        "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        "David S. Miller" <davem@davemloft.net>,
        Vladimir Kondratiev <vkondra@mail.ru>, netdev@oss.sgi.com,
        acx100-devel@lists.sourceforge.net, hadi@cyberus.ca,
        jkmaline@cc.hut.fi, prism54-devel@prism54.org, sam@errno.com,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4147989C.7030708@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 14, 2004 at 09:19:24PM -0400, Jeff Garzik wrote:
> greg chesson wrote:
> >I won't try to argue that these are not valid points -
> >except for maybe the last one because it is so subjective.
> >But not in this email.
> >
> >I do argue that these points are not relevant to the question
> >of  whether or not a strict stack model of 802.11 management
> >and encapsulation procedures will suffice for anything more
> >than the most basic functionality.   That is an interesting question
> >that deserves an answer.
> 
> Agreed.
> 
> 
> >Personally, I think it will be necessary to have more shared information 
> >and procedures between
> >driver and 802.11 stack than is convenient or elegant in a strict stack 
> >arrangement.
> > But, I've been wrong before.
> >Perhaps a fresh start with unbiased implementation will do something 
> >wonderful.
> 
> That's precisely what I want -- an elegant strict stack arrangement :)
> 
> Since DaveM's template is _the_ net stack, I'm worried that BSD 
> compatibility will only slow development and encumber innovation. 
> Surely they can watch what we're doing, learn from our mistakes, and do 
> something even better :)

I proposed dual licensing not to specifically allow clear compatibility
among linux and the BSDs on the 802.11 work, but to allow BSDers to do
whatever they want with what we come up with -- help with code sharing.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
