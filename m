From: Thomas Sailer <t.sailer@alumni.ethz.ch>
Subject: Re: [PATCH] - drivers/net/hamradio remove local random function,
	use random32()
Date: Fri, 16 Feb 2007 11:50:31 +0100
Message-ID: <1171623031.3139.56.camel@playstation2.hb9jnx.ampr.org>
References: <1171596978.29021.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org, jpr@f6fbb.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1171596978.29021.64.camel@localhost>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-02-15 at 19:36 -0800, Joe Perches wrote:
> remove local random function, use random32() instead
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-By: Thomas Sailer <t.sailer@alumni.ethz.ch>

There are a bunch of other drivers with their homegrown random number
function, namely 6pack.c dmascc.c hdlcdrv.c yam.c.

Can you do a patch for those too?

Thanks a lot,

Tom



