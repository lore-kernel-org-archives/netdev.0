From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 05/13] M68k Ethernet drivers depend on NET_ETHERNET
Date: Wed, 24 Nov 2004 00:24:42 -0800
Message-ID: <20041124002442.555512a9.davem@davemloft.net>
References: <200411220644.iAM6i4900638@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200411220644.iAM6i4900638@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 21 Nov 2004 22:43:52 -0800
akpm@osdl.org wrote:

> From: Geert Uytterhoeven <geert@linux-m68k.org>
> 
> M68k Ethernet drivers depend on NET_ETHERNET instead of NETDEVICES
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

drivers/net, so looks like something in Jeff's territory.
