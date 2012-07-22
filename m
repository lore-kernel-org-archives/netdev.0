From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] net: ethernet: davinci_emac: fixups + pm_runtime
Date: Sun, 22 Jul 2012 12:46:57 -0700 (PDT)
Message-ID: <20120722.124657.1259861132979869204.davem@davemloft.net>
References: <1342833562-3435-1-git-send-email-mgreer@animalcreek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: mgreer@animalcreek.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1342833562-3435-1-git-send-email-mgreer@animalcreek.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mark A. Greer" <mgreer@animalcreek.com>
Date: Fri, 20 Jul 2012 18:19:20 -0700

> From: "Mark A. Greer" <mgreer@animalcreek.com>
> 
> This series fixes a compile error in, and adds pm_runtime support
> to, the davinci_emac driver.
> 
> To test on a davinci platform, you will need another patch just
> submitted to netdev:
> 
> 	http://marc.info/?l=linux-netdev&m=134282758408187&w=2
> 
> Mark A. Greer (2):
>   net: ethernet: davinci_emac: Remove unnecessary #include
>   net: ethernet: davinci_emac: add pm_runtime support

All applied to net-next, thanks.
