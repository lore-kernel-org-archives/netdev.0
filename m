From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] PCH_GbE : Fixed the issue of checksum judgment
Date: Mon, 09 May 2011 11:55:35 -0700 (PDT)
Message-ID: <20110509.115535.115940298.davem@davemloft.net>
References: <4DC3EF64.9050305@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tomoya-linux@dsn.okisemi.com,
	linux-kernel@vger.kernel.org, qi.wang@intel.com,
	yong.y.wang@intel.com, andrew.chih.howe.khor@intel.com,
	joel.clark@intel.com, kok.howg.ewe@intel.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DC3EF64.9050305@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Fri, 06 May 2011 21:53:56 +0900

> The checksum judgment was mistaken.
>   Judgment result
>      0:Correct 1:Wrong
> 
> This patch fixes the issue.
> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>

Applied.
