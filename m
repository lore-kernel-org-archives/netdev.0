From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [2.6 patch] drivers/net/wireless/ipw2200.c: fix an array overun
Date: Fri, 17 Mar 2006 20:13:47 -0500
Message-ID: <20060318011342.GG25249@tuxdriver.com>
References: <20060311034258.GJ21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yi.zhu@intel.com, jketreno@linux.intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932840AbWCRBRG@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060311034258.GJ21864@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 11, 2006 at 04:42:58AM +0100, Adrian Bunk wrote:
> This patch fixes a big array overun found by the Coverity checker.

Merged to upstream branch of wireless-2.6...thanks!

John
-- 
John W. Linville
linville@tuxdriver.com
