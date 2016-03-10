From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 0/4] net-next: mediatek: add ethernet driver
Date: Thu, 10 Mar 2016 16:22:36 -0500 (EST)
Message-ID: <20160310.162236.155620180825637848.davem@davemloft.net>
References: <1457432997-25526-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, steven.liu@mediatek.com,
	Carlos.Huang@mediatek.com, nbd@openwrt.org, igvtee@gmail.com
To: blogic@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457432997-25526-1-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <blogic@openwrt.org>
Date: Tue,  8 Mar 2016 11:29:53 +0100

> This series adds support for the Mediatek ethernet core found on current ARM
> based SoCs. The driver works on MT2701 and MT7623 SoCs
> 
> Instead of trying to upstream everything at once I decided to concentrate on
> the important parts required to make current generation silicon work. The V3
> series only includes the code required to make dual MAC setups work and only
> supports the newer QDMA engine.
 ...

Series applied, thanks.
