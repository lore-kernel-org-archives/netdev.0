From: "David S. Miller" <davem@davemloft.net>
Subject: Re: patch: introduce simple actions
Date: Tue, 22 Mar 2005 19:58:27 -0800
Message-ID: <20050322195827.5ecd0c33.davem@davemloft.net>
References: <1111345551.1095.82.camel@jzny.localdomain>
	<423DCD8C.6030100@trash.net>
	<1111347345.1094.98.camel@jzny.localdomain>
	<423DD5E6.2020708@trash.net>
	<1111349853.1093.136.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com, tgraf@suug.ch
To: hadi@znyx.com
In-Reply-To: <1111349853.1093.136.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 20 Mar 2005 15:17:34 -0500
Jamal Hadi Salim <hadi@znyx.com> wrote:

> How about this:
> I submit this patch (with Thomas cleanup) and the simple action.

I'm waiting for this, send whenever it's ready.

You may want to add the standard stuff to that header
file BTW, ala:

/* foo.h: This is the foo interface header.
 *
 * Copyright (C) 2005 Jamal Hadi Salim <hadi@cyberus.ca>
 */

#ifndef _NET_FOO_H
#define _NET_FOO_H
 ...
#endif /* _NET_FOO_H */
