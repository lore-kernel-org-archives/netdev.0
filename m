From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 21:27:02 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301082122190.32244-100000@dns.toxicfilms.tv>
References: <78180000.1042055993@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Fabio Massimo Di Nitto <fabbione@fabbione.net>,
   Wichert Akkerman <wichert@wiggy.net>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew McGregor <andrew@indranet.co.nz>
In-Reply-To: <78180000.1042055993@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Probably on the server's side it got an ICMP Host Unreachable or two as
> some router updated its tables, and decided to close the connection.
Sounds reasonable to me. Could it mean that this router that we are
talking about is simply slow or overloaded ?

Maciej
