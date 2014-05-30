From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/18] r8152: Use kmemdup instead of kmalloc + memcpy
Date: Fri, 30 May 2014 16:25:50 -0700 (PDT)
Message-ID: <20140530.162550.1648501676114480780.davem@davemloft.net>
References: <1401117687-28911-1-git-send-email-benoit.taine@lip6.fr>
	<1401117687-28911-15-git-send-email-benoit.taine@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: benoit.taine@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401117687-28911-15-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Taine <benoit.taine@lip6.fr>
Date: Mon, 26 May 2014 17:21:23 +0200

> This issue was reported by coccicheck using the semantic patch 
> at scripts/coccinelle/api/memdup.cocci
> 
> Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>
> ---
> Tested by compilation without errors.

Applied to net-next, thank you.
