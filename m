From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 09/13] M68k: Update Atari defconfig (enable Ethernet and
 MII)
Date: Wed, 24 Nov 2004 00:26:05 -0800
Message-ID: <20041124002605.7812a93d.davem@davemloft.net>
References: <200411220644.iAM6i7900667@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200411220644.iAM6i7900667@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 21 Nov 2004 22:43:55 -0800
akpm@osdl.org wrote:

> From: Geert Uytterhoeven <geert@linux-m68k.org>
> 
> M68k: Update Atari defconfig (enable Ethernet and MII)
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

I think this can go straight in, it's arch/m68k stuff not
necessarily something networking maintainers should be
pushing around :)
