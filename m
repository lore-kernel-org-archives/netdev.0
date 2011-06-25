From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] 8390: Neatening
Date: Fri, 24 Jun 2011 17:31:52 -0700 (PDT)
Message-ID: <20110624.173152.1603347362416638729.davem@davemloft.net>
References: <cover.1308810463.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1308810463.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 22 Jun 2011 23:38:52 -0700

> Some updates requested by Geert Uytterhoeven
> 
> Joe Perches (8):
>   ariadne: Update style, neaten, restructure to eliminate prototypes
>   a2065: Use pr_fmt, pr_<level> and netdev_<level>
>   lib8390: Use pr_<level> and netdev_<level>
>   lib8390: Indent braces appropriately
>   lib8390: Normalize source code spacing
>   lib8390: Convert include <asm to include <linux
>   lib8390: Remove unnecessary extern
>   zorro8390: Restructure and eliminate prototypes

All applied, thanks Joe.
