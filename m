From: Fabio Massimo Di Nitto <fabbione@fabbione.net>
Subject: [OT] Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 21:31:04 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0301082129180.12716@diapolon.int.fabbione.net>
References: <Pine.LNX.4.44.0301082122190.32244-100000@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew McGregor <andrew@indranet.co.nz>,
   Wichert Akkerman <wichert@wiggy.net>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
In-Reply-To: <Pine.LNX.4.44.0301082122190.32244-100000@dns.toxicfilms.tv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Definitly it is somehow unstable. Difficult to find the reason.
Anyway Im sure that there is asimmetric routing between me and
ipv6.lkml.org and I could see pkts coming back. It might not have been the
case for Wichert

Fabio

On Wed, 8 Jan 2003, Maciej Soltysiak wrote:

> > Probably on the server's side it got an ICMP Host Unreachable or two as
> > some router updated its tables, and decided to close the connection.
> Sounds reasonable to me. Could it mean that this router that we are
> talking about is simply slow or overloaded ?
>
> Maciej
>
>
>
