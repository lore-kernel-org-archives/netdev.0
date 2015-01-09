From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh-eth: Set fdr_value of R-Car SoCs
Date: Thu, 08 Jan 2015 20:07:21 -0800 (PST)
Message-ID: <20150108.200721.876347819297120875.davem@davemloft.net>
References: <1420609215-6969-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com,
	linux-sh@vger.kernel.org
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1420609215-6969-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Wed,  7 Jan 2015 14:40:15 +0900

> FDR register of R-Car set in fdr_value can have the original settings.
> This sets the value that is suitable for each SoCs to fdr_value of R8A777x
> and R8A779x.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Applied.
