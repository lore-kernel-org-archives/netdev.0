From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ks8851: Drop eeprom_size structure member
Date: Tue, 24 Jan 2017 14:56:56 -0500 (EST)
Message-ID: <20170124.145656.2203396505942628067.davem@davemloft.net>
References: <20170124014920.644-1-stephen.boyd@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stephen.boyd@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124014920.644-1-stephen.boyd@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <stephen.boyd@linaro.org>
Date: Mon, 23 Jan 2017 17:49:20 -0800

> After commit 51b7b1c34e19 (KSZ8851-SNL: Add ethtool support for
> EEPROM via eeprom_93cx6, 2011-11-21) this structure member is
> unused. Delete it.
> 
> Signed-off-by: Stephen Boyd <stephen.boyd@linaro.org>

Applied to net-next, thanks.
