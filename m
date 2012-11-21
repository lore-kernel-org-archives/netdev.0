From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-11-21
Date: Wed, 21 Nov 2012 11:49:27 -0500 (EST)
Message-ID: <20121121.114927.2236597401100258829.davem@davemloft.net>
References: <20121121162406.GA2066@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121121162406.GA2066@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 21 Nov 2012 11:24:06 -0500

> Included are two pulls.  Regarding the mac80211 tree, Johannes says:
> 
> "Please pull my mac80211.git tree (see below) to get two more fixes for
> 3.7. Both fix regressions introduced *before* this cycle that weren't
> noticed until now, one for IBSS not cleaning up properly and the other
> to add back the "wireless" sysfs directory for Fedora's startup scripts."
> 
> Regarding the iwlwifi tree, Johannes says:
> 
> "Please also pull my iwlwifi.git tree, I have two fixes: one to remove a
> spurious warning that can actually trigger in legitimate situations, and
> the other to fix a regression from when monitor mode was changed to use
> the "sniffer" firmware mode."
> 
> Also included is an nfc tree pull.  Samuel says:
> 
> "We mostly have pn533 fixes here, 2 memory leaks and an early unlocking fix.
> Moreover, we also have an LLCP adapter linked list insertion fix."
> 
> On top of that, a few more bits...  Albert Pool adds a USB ID
> to rtlwifi.  Bing Zhao provides two mwifiex fixes -- one to fix
> a system hang during a command timeout, and the other to properly
> report a suspend error to the MMC core.  Finally, Sujith Manoharan
> fixes a thinko that would trigger an ath9k hang during device reset.

Pulled, thanks John.
