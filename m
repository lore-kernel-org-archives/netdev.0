From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/2] net: ethernet: mediatek: modify to use
 the PDMA for Ethernet RX
Date: Fri, 26 Aug 2016 21:07:16 -0700 (PDT)
Message-ID: <20160826.210716.476405113982102387.davem@davemloft.net>
References: <1472144983-5048-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 nelsonch.tw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org
To: nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472144983-5048-1-git-send-email-nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Date: Fri, 26 Aug 2016 01:09:41 +0800

> This series have some modifications and refines to support Ethernet RX by the PDMA.
> 
> changes since v4:
> - Remove the redundant OR operation in mtk_hw_init()
> 
> changes since v3:
> - Add GDM hardware settings to send packets to PDMA for RX
> 
> changes since v2:
> - Fix the bugs of PDMA cpu index and interrupt settings in mtk_poll_rx()
> 
> changes since v1:
> - Modify to use the PDMA instead of the QDMA for Ethernet RX

Series applied, thanks.
