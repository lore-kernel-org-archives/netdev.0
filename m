From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-10-09
Date: Wed, 09 Oct 2013 14:04:21 -0400 (EDT)
Message-ID: <20131009.140421.1066887211157494658.davem@davemloft.net>
References: <20131009152841.GD14381@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131009152841.GD14381@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 9 Oct 2013 11:28:41 -0400

> Please pull this batch of fixes intended for 3.12...
> 
> Most of the bits are for iwlwifi -- Johannes says:
> 
> "I have a fix for WoWLAN/D3, a PCIe device fix, we're removing a
> warning, there's a fix for RF-kill while scanning (which goes together
> with a mac80211 fix) and last but not least we have many new PCI IDs."
> 
> Also for iwlwifi is a patch from Johannes to correct some merge damage
> that crept into the tree before the last merge window.
> 
> On top of that, Felix Fietkau sends an ath9k patch to avoid a Tx
> scheduling hang when changing channels to do a scan.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
