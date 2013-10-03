From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-10-03
Date: Thu, 03 Oct 2013 16:54:04 -0400 (EDT)
Message-ID: <20131003.165404.1304983997786923256.davem@davemloft.net>
References: <20131003201023.GC3142@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131003201023.GC3142@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 3 Oct 2013 16:10:24 -0400

> Here is another batch of fixes intended for the 3.12 stream...
> 
> For the mac80211 bits, Johannes says:
> 
> "This time I have two fixes for IBSS (including one for wext, hah), a fix
> for extended rates IEs, an active monitor checking fix and a sysfs
> registration race fix."
> 
> On top of those...
> 
> Amitkumar Karwar brings an mwifiex fix for an interrupt loss issue
> w/ SDIO devices.  The problem was due to a command timeout issue
> introduced by an earlier patch.
> 
> Felix Fietkau a stall in the ath9k driver.  This patch fixes the
> regression introduced in the commit "ath9k: use software queues for
> un-aggregated data packets".
> 
> Stanislaw Gruszka reverts an rt2x00 patch that was found to cause
> connection problems with some devices.
> 
> Please let me know if there are problems!

Pulled, thanks John.
