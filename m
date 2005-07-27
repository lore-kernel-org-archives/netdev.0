From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] NETCONSOLE must depend on INET
Date: Tue, 26 Jul 2005 17:03:49 -0700 (PDT)
Message-ID: <20050726.170349.10935659.davem@davemloft.net>
References: <20050726232043.GB7425@waste.org>
	<20050726.163202.119887768.davem@davemloft.net>
	<20050726235824.GN12006@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262425AbVG0AFB@vger.kernel.org>
To: mpm@selenic.com
In-Reply-To: <20050726235824.GN12006@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Tue, 26 Jul 2005 16:58:24 -0700

> On Tue, Jul 26, 2005 at 04:32:02PM -0700, David S. Miller wrote:
> > More seriously, please submit a version of whatever you
> > believe to be the more correct fix so it can be reviewed
> > and integrated.
> 
> Do you have a preferred location to put this function or
> shall I invent one?

I actually can't wait to see where you're going to
to put a function that transforms "IPV4 addresses"
from ascii other than some place protected by CONFIG_INET.
:-)
