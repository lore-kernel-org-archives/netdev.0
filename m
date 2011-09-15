From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/3] pch_gbe: fixed the issue which receives an
 unnecessary packet.
Date: Thu, 15 Sep 2011 17:25:58 -0400 (EDT)
Message-ID: <20110915.172558.450897137285997811.davem@redhat.com>
References: <1314922809-4041-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, qi.wang@intel.com, yong.y.wang@intel.com,
	joel.clark@intel.com, kok.howg.ewe@intel.com,
	tomoya-linux@dsn.okisemi.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314922809-4041-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Fri,  2 Sep 2011 09:20:07 +0900

> This patch fixed the issue which receives an unnecessary packet before link
> 
> When using PHY of GMII, an unnecessary packet is received,
> And it becomes impossible to receive a packet after link up.
> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>

Applied.
