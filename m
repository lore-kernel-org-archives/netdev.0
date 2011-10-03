From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] pch_gbe: Fixed the issue on which a network freezes
Date: Mon, 03 Oct 2011 14:25:59 -0400 (EDT)
Message-ID: <20111003.142559.2285791137343264317.davem@davemloft.net>
References: <1317022063-12143-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
	<1317022063-12143-2-git-send-email-toshiharu-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, qi.wang@intel.com, yong.y.wang@intel.com,
	joel.clark@intel.com, kok.howg.ewe@intel.com,
	tomoya-linux@dsn.okisemi.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317022063-12143-2-git-send-email-toshiharu-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Mon, 26 Sep 2011 16:27:43 +0900

> The pch_gbe driver has an issue which a network stops,
> when receiving traffic is high.
> In the case, The link down and up are necessary to return a network.
> 
> This patch fixed this issue.
> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>

Applied.
