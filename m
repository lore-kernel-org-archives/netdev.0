From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] NETCONSOLE must depend on INET
Date: Wed, 27 Jul 2005 13:19:00 -0700 (PDT)
Message-ID: <20050727.131900.59654701.davem@davemloft.net>
References: <20050726235824.GN12006@waste.org>
	<20050726.170349.10935659.davem@davemloft.net>
	<20050727023636.GP12006@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261213AbVG0WtD@vger.kernel.org>
To: mpm@selenic.com
In-Reply-To: <20050727023636.GP12006@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Tue, 26 Jul 2005 19:36:37 -0700

> # HG changeset patch
> # User mpm@selenic.com
> # Node ID 6cdd6f36d53678a016cfbf5ce667cbd91504d538
> # Parent  75716ae25f9d87ee2a5ef7c4df2d8f86e0f3f762
> Move in_aton from net/ipv4/utils.c to net/core/utils.c

This patch doesn't apply, in the current 2.6.x GIT tree
NETCONSOLE does not depend on NETDEVICES.

Please fix up this patch so that I can apply it.
Thanks.
