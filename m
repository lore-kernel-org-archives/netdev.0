From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Wed, 12 Nov 2003 01:41:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112004123.GA2749@wsx.ksp.sk>
References: <20031109122844.GA14241@wsx.ksp.sk> <20031110214603.0057e365.davem@redhat.com> <20031111222611.GA1239@wsx.ksp.sk> <20031111151340.3d129bc7.davem@redhat.com>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031111151340.3d129bc7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Yes there is a gdb, here is a prebuilt 64-bit gdb for you.  It is even
> statically linked so there are no shared library dependencies.  It can
> debug 32-bit processes as well:
> 
> 	ftp://pizda.ninka.net/pub/for_jakub/gdb64

Thanks a lot!

That is exactly what I was looking for, now I can debug IPv4 traceroute :-).


Jan
