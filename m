From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/core/user_dma.c should #include <net/netdma.h>
Date: Tue, 18 Jul 2006 13:30:27 -0700 (PDT)
Message-ID: <20060718.133027.102614767.davem@davemloft.net>
References: <20060715003617.GL3633@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932389AbWGRUaI@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060715003617.GL3633@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 15 Jul 2006 02:36:17 +0200

> Every file should #include the headers containing the prototypes for 
> its global functions.
> 
> Especially in cases like this one where gcc can tell us through a 
> compile error that the prototype was wrong...
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
