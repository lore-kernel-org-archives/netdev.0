From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [2.6 patch] drivers/net/wireless/ipw2200.c: make ipw_qos_current_mode() static
Date: Fri, 17 Mar 2006 20:11:35 -0500
Message-ID: <20060318011130.GC25249@tuxdriver.com>
References: <20060304121431.GN9295@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yi.zhu@intel.com, jketreno@linux.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932304AbWCRBO5@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060304121431.GN9295@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 04, 2006 at 01:14:31PM +0100, Adrian Bunk wrote:
> This patch makes the needlessly global function ipw_qos_current_mode() 
> static.

Merged to upstream branch of wireless-2.6...thanks!

John
-- 
John W. Linville
linville@tuxdriver.com
