From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2014-10-09
Date: Fri, 10 Oct 2014 14:50:17 -0400 (EDT)
Message-ID: <20141010.145017.157815509134709496.davem@davemloft.net>
References: <20141009154402.GB13986@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141009154402.GB13986@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 9 Oct 2014 11:44:02 -0400

> Please pull this batch of fixes intended for the 3.18 stream!
> 
> Andrea Merello makes rtl818x_pci use a more reasonable transmission
> rate for HW generated frames.
> 
> Fabian Frederick tweaks some kernel-doc bits to avoid warnings.
> 
> Larry Finger corrects a possible unaligned access in the rtlwifi code.
> 
> Marek Puzyniak avoids a kernel panic in ath9k_hw_reset.
> 
> Sujith Manoharan goes for the hat trick -- he fixes a smatch warning
> in the shared ath code, he fixes a crash in ath9k, and he corrects
> a sequence number assignment problem in ath9k too.
> 
> For ease of merging, I pulled the last bits of the wireless tree as well...
> 
> Please let me know if there are problems!

Pulled, thank you John.
