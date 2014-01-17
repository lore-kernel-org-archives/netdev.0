From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_mdio: Fix sparse warning
Date: Thu, 16 Jan 2014 17:30:09 -0800 (PST)
Message-ID: <20140116.173009.1297466601669773596.davem@davemloft.net>
References: <1389852341-15393-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mugunthanvnm@ti.com
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389852341-15393-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Date: Thu, 16 Jan 2014 11:35:41 +0530

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> This patch fixes following sparse warning
> davinci_mdio.c:85:27: warning: symbol 'default_pdata' was not declared. Should it be static?
> Also makes the default_pdata as a constant.
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
