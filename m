From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: generic 802.11 stack
Date: Tue, 14 Sep 2004 21:19:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4147989C.7030708@pobox.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <4145352F.4040807@pobox.com> <20040913162153.33ff37ec.davem@davemloft.net> <200409140819.25787.vkondra@mail.ru> <20040913223500.66c06cde.davem@davemloft.net> <20040914235512.GJ7839@ruslug.rutgers.edu> <414788A4.7070003@pobox.com> <41479228.8080507@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        "David S. Miller" <davem@davemloft.net>,
        Vladimir Kondratiev <vkondra@mail.ru>, netdev@oss.sgi.com,
        acx100-devel@lists.sourceforge.net, hadi@cyberus.ca,
        jkmaline@cc.hut.fi, prism54-devel@prism54.org, sam@errno.com,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: greg chesson <greg@atheros.com>
In-Reply-To: <41479228.8080507@atheros.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

greg chesson wrote:
> I won't try to argue that these are not valid points -
> except for maybe the last one because it is so subjective.
> But not in this email.
> 
> I do argue that these points are not relevant to the question
> of  whether or not a strict stack model of 802.11 management
> and encapsulation procedures will suffice for anything more
> than the most basic functionality.   That is an interesting question
> that deserves an answer.

Agreed.


> Personally, I think it will be necessary to have more shared information 
> and procedures between
> driver and 802.11 stack than is convenient or elegant in a strict stack 
> arrangement.
>  But, I've been wrong before.
> Perhaps a fresh start with unbiased implementation will do something 
> wonderful.

That's precisely what I want -- an elegant strict stack arrangement :)

Since DaveM's template is _the_ net stack, I'm worried that BSD 
compatibility will only slow development and encumber innovation. 
Surely they can watch what we're doing, learn from our mistakes, and do 
something even better :)

	Jeff
