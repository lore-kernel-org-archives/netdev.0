From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] pch_gbe: Fix the issue that the receiving data is
 not normal.
Date: Sun, 13 Feb 2011 21:51:08 -0800 (PST)
Message-ID: <20110213.215108.35810735.davem@davemloft.net>
References: <4D524D3F.70906@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tomoya-linux@dsn.okisemi.com,
	linux-kernel@vger.kernel.org, qi.wang@intel.com,
	yong.y.wang@intel.com, andrew.chih.howe.khor@intel.com,
	joel.clark@intel.com, kok.howg.ewe@intel.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D524D3F.70906@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Wed, 09 Feb 2011 17:15:59 +0900

> This PCH_GBE driver had an issue that the receiving data is not normal.
> This driver had not removed correctly the padding data 
> which the DMA include in receiving data. 
> 
> This patch fixed this issue.
> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>

Applied, thank you.
