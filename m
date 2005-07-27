From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] NETCONSOLE must depend on INET
Date: Wed, 27 Jul 2005 14:13:41 -0700 (PDT)
Message-ID: <20050727.141341.21926817.davem@davemloft.net>
References: <20050727023636.GP12006@waste.org>
	<20050727.131900.59654701.davem@davemloft.net>
	<20050727204622.GI12006@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262145AbVG0VOA@vger.kernel.org>
To: mpm@selenic.com
In-Reply-To: <20050727204622.GI12006@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 27 Jul 2005 13:46:22 -0700

> Odd, gitweb of Linus' tree seems to disagree. I see it depends on
> NETDEVICES && INET && EXPERIMENTAL. NETDEVICES has been there since
> the beginning of git history and according to my Mercurial import from
> BKCVS, it's been dependent on NETDEVICES since I first submitted it.

Sorry, that's a result of a local change I just added
to fix up presentation the net device family Kconfig's.
