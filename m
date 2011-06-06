From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-06-06
Date: Mon, 06 Jun 2011 13:25:49 -0700 (PDT)
Message-ID: <20110606.132549.1074295213687787615.davem@davemloft.net>
References: <20110606190427.GH2604@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110606190427.GH2604@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 6 Jun 2011 15:04:27 -0400

> Here are a few more fixes intended for 3.0 -- a libertas fix for a
> regression related to spurious interrupts, an ath5k fix to disable
> "fast" channel switching (since it caused a number of devices to
> regress in performance), an ssb fix for a regression that was applying
> PCIe workarounds to PCI devices (causing a machine check), an fix for an
> iwlagn locking regression, and a mac80211 fix for a device-naming
> regression.
> 
> Please let me know if there are problems!

Pulled, thanks John.
