From: Fabio Massimo Di Nitto <fabbione@fabbione.net>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Thu, 9 Jan 2003 08:29:19 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0301090822001.19862@trider-g7.ext.fabbione.net>
References: <20030108130850.GQ22951@wiggy.net>
 <Pine.LNX.4.51.0301081849550.564@diapolon.int.fabbione.net>
 <78180000.1042055993@localhost.localdomain> <20030108224339.GO22951@wiggy.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew McGregor <andrew@indranet.co.nz>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20030108224339.GO22951@wiggy.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 8 Jan 2003, Wichert Akkerman wrote:

> Previously Andrew McGregor wrote:
> > Probably on the server's side it got an ICMP Host Unreachable or two as
> > some router updated its tables, and decided to close the connection.
>
> The fact that this problem does not seem to occur when using a window
> XP client seems to contradict the suggestions that it may be a router
> problem.
>
> Wichert.
>
>

Is the WinXP client located in the same place where you are?

>From my side the ISP that is giving me problems is xs26.net
at 2 different points. One is flapping and one is the link between them
and another ISP (i can't even reach it now) where pkts get seriously
delayed (from 100ms to more than 350ms) probably due to a slow link.
But what is seriously annoying is that xs26.net keeps announcing a network
that it can't reach, fscking the entire routing.

Fabio
