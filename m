From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: patch: introduce simple actions
Date: 22 Mar 2005 23:06:39 -0500
Message-ID: <1111550799.1116.28.camel@jzny.localdomain>
References: <1111345551.1095.82.camel@jzny.localdomain>
	 <423DCD8C.6030100@trash.net> <1111347345.1094.98.camel@jzny.localdomain>
	 <423DD5E6.2020708@trash.net> <1111349853.1093.136.camel@jzny.localdomain>
	 <20050322195827.5ecd0c33.davem@davemloft.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com, tgraf@suug.ch
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050322195827.5ecd0c33.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-22 at 22:58, David S. Miller wrote:
> On 20 Mar 2005 15:17:34 -0500
> Jamal Hadi Salim <hadi@znyx.com> wrote:
> 
> > How about this:
> > I submit this patch (with Thomas cleanup) and the simple action.
> 
> I'm waiting for this, send whenever it's ready.
> 

I will tommorow - need to plonk tonight 

> You may want to add the standard stuff to that header
> file BTW, ala:
> 
> /* foo.h: This is the foo interface header.
>  *
>  * Copyright (C) 2005 Jamal Hadi Salim <hadi@cyberus.ca>
>  */
> 
> #ifndef _NET_FOO_H
> #define _NET_FOO_H
>  ...
> #endif /* _NET_FOO_H */

dang, yes. Thanks - will do.

cheers,
jamal
