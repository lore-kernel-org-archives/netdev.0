From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: davinci_mdio: Fix sparse warning
Date: Thu, 16 Jan 2014 11:44:52 +0530
Message-ID: <52D778DC.8020607@ti.com>
References: <1389852341-15393-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Prabhakar Lad <prabhakar.csengg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389852341-15393-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 16 January 2014 11:35 AM, Prabhakar Lad wrote:
> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>
> This patch fixes following sparse warning
> davinci_mdio.c:85:27: warning: symbol 'default_pdata' was not declared. Should it be static?
> Also makes the default_pdata as a constant.
>
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
