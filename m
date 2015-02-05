From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti/cpsw-common.c: fix sparse warning
Date: Thu, 05 Feb 2015 00:28:00 -0800 (PST)
Message-ID: <20150205.002800.2141037681825709908.davem@davemloft.net>
References: <1423053088-6589-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tony@atomide.com
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423053088-6589-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Wed,  4 Feb 2015 12:31:28 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> 
> cpsw-common.c:23:5: warning: symbol 'cpsw_am33xx_cm_get_macid' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
