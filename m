From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Rename "phy-reset-active-low" property
Date: Sun, 06 Mar 2016 22:47:32 -0500 (EST)
Message-ID: <20160306.224732.304255287762000853.davem@davemloft.net>
References: <1456996555-7500-1-git-send-email-bernhard@bwalle.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bernhard@bwalle.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456996555-7500-1-git-send-email-bernhard@bwalle.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernhard Walle <bernhard@bwalle.de>
Date: Thu,  3 Mar 2016 10:15:55 +0100

> From the perspective of RESET, the meaning of the new property
> is actually "active high". Thanks for Troy Kisky for pointing
> that out.
> 
> Since the patch is in linux-next, this patch is incremental and doesn't
> replace the original patch.
> 
> Signed-off-by: Bernhard Walle <bernhard@bwalle.de>

Applied.
