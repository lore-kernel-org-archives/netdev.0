From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 23:43:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030108224339.GO22951@wiggy.net>
References: <20030108130850.GQ22951@wiggy.net> <Pine.LNX.4.51.0301081849550.564@diapolon.int.fabbione.net> <78180000.1042055993@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fabio Massimo Di Nitto <fabbione@fabbione.net>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew McGregor <andrew@indranet.co.nz>
Content-Disposition: inline
In-Reply-To: <78180000.1042055993@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Andrew McGregor wrote:
> Probably on the server's side it got an ICMP Host Unreachable or two as 
> some router updated its tables, and decided to close the connection.

The fact that this problem does not seem to occur when using a window
XP client seems to contradict the suggestions that it may be a router
problem.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>           http://www.wiggy.net/
A random hacker
