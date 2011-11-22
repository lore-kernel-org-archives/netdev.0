From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2011-11-22 #2
Date: Tue, 22 Nov 2011 18:17:57 -0500 (EST)
Message-ID: <20111122.181757.1296497307756213535.davem@davemloft.net>
References: <20111122215611.GI8452@tuxdriver.com>
	<20111122.173729.1155753802137219940.davem@davemloft.net>
	<20111122224108.GJ8452@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111122224108.GJ8452@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 22 Nov 2011 17:41:08 -0500

> On Tue, Nov 22, 2011 at 05:37:29PM -0500, David Miller wrote:
> ...
> They're here...
> 
>> 0003-rt2x00-Fix-efuse-EEPROM-reading-on-PPC32.patch
>> 0004-p54spi-Add-missing-spin_lock_init.patch
>> 0005-p54spi-Fix-workqueue-deadlock.patch
>> 0006-mac80211-Fix-AMSDU-rate-printout-in-debugfs.patch
>> 0007-mac80211-Fix-endian-bug-in-radiotap-header-generatio.patch
>> 0008-cfg80211-fix-regulatory-NULL-dereference.patch
>> 0009-prism54-potential-memory-corruption-in-prism54_get_e.patch
>> 0010-Revert-rt2x00-handle-spurious-pci-interrupts.patch
>> 0011-Revert-rt2800pci-handle-spurious-interrupts.patch
> 
> And I revert them here.
> 
> Linus always says to live with our mistakes?  I was trying to avoid
> a rebase both for my own pain and that of my downstream maintainers.

Gotcha, I'll repull, thanks.
