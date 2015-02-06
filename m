From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bnx2x: fix sparse warnings
Date: Thu, 05 Feb 2015 16:05:53 -0800 (PST)
Message-ID: <20150205.160553.2079538425644280496.davem@davemloft.net>
References: <1423151237-20746-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423151237-20746-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Thu,  5 Feb 2015 15:47:17 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warnings:
> 
> bnx2x_main.c:9172:6: warning: symbol 'bnx2x_stop_ptp' was not declared. Should it be static?
> bnx2x_main.c:13321:6: warning: symbol 'bnx2x_register_phc' was not declared. Should it be static?
> bnx2x_main.c:14638:5: warning: symbol 'bnx2x_enable_ptp_packets' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
