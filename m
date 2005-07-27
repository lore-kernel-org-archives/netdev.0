From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] NETCONSOLE must depend on INET
Date: Tue, 26 Jul 2005 19:53:20 -0700 (PDT)
Message-ID: <20050726.195320.89085462.davem@davemloft.net>
References: <20050726235824.GN12006@waste.org>
	<20050726.170349.10935659.davem@davemloft.net>
	<20050727023636.GP12006@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262298AbVG0CxG@vger.kernel.org>
To: mpm@selenic.com
In-Reply-To: <20050727023636.GP12006@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Tue, 26 Jul 2005 19:36:37 -0700

> [sch added to cc: as I think he's the effective pktgen maintainer]

No, that would be Robert Olsson.

> Move in_aton from net/ipv4/utils.c to net/core/utils.c

Fair enough.
