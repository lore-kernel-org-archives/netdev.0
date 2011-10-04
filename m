From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] NET: fix phy init for Asix AX88178 USB (GigE)
Date: Tue, 04 Oct 2011 16:26:16 -0400 (EDT)
Message-ID: <20111004.162616.1293120763854321339.davem@davemloft.net>
References: <1317758118-24052-1-git-send-email-grundler@chromium.org>
	<1317758118-24052-2-git-send-email-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, freddy@asix.com.tw
To: grundler@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317758118-24052-2-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@chromium.org>
Date: Tue,  4 Oct 2011 12:55:17 -0700

> Asix provided this patch and I've confirmed "Plugable USB2-E1000" and
> "Shenzhen Winstars NWU220G" USB dongles can get a link and TX/RX data.
> 
> Signed-off-by: "Freddy Xin" <freddy@asix.com.tw>
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Applied to net-next-2.6
