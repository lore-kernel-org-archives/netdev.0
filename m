From: Matt Mackall <mpm@selenic.com>
Subject: Re: [2.6 patch] drivers/char/random.c: unexport secure_ipv6_port_ephemeral
Date: Sun, 9 Apr 2006 11:56:16 -0500
Message-ID: <20060409165616.GW15445@waste.org>
References: <20060409155822.GI8454@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750822AbWDIQ5N@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060409155822.GI8454@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 09, 2006 at 05:58:22PM +0200, Adrian Bunk wrote:
> This patch removes the unused EXPORT_SYMBOL(secure_ipv6_port_ephemeral).

> Signed-off-by: Adrian Bunk <bunk@stusta.de>
Acked-by: Matt Mackall <mpm@selenic.com>

Adrian appears to be correct that this doesn't break modular ipv6.
-- 
Mathematics is the supreme nostalgia of our time.
