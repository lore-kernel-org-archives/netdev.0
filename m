From: James Morris <jmorris@intercode.com.au>
Subject: Re: ipsec / pppoe
Date: Sun, 1 Jun 2003 22:18:56 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306012217330.18182-100000@excalibur.intercode.com.au>
References: <200306011233.22544.aj@dungeon.inka.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <howto@lartc.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Jellinghaus <aj@dungeon.inka.de>
In-Reply-To: <200306011233.22544.aj@dungeon.inka.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 1 Jun 2003, Andreas Jellinghaus wrote:

> cc: to howto@lartc.org, it think this would make a nice
> howto entry.

Actually, there is a bug in the way icmp pmtu messages are being generated 
here, which should be fixed soon.


- James
-- 
James Morris
<jmorris@intercode.com.au>
