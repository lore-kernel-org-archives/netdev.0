From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-09-17
Date: Fri, 19 Sep 2014 16:33:59 -0400 (EDT)
Message-ID: <20140919.163359.1720346114199249960.davem@davemloft.net>
References: <20140917152300.GB13392@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140917152300.GB13392@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 17 Sep 2014 11:23:01 -0400

> Please pull this batch of fixes intended for the 3.17 stream...
> 
> Arend van Spriel sends a trio of minor brcmfmac fixes, including a
> fix for a Kconfig/build issue, a fix for a crash (null reference),
> and a regression fix related to event handling on a P2P interface.
> 
> Hante Meuleman follows-up with a brcmfmac fix for a memory leak.
> 
> Johannes Stezenbach brings an ath9k_htc fix for a regression related
> to hardware decryption offload.
> 
> Marcel Holtmann delivers a one-liner to properly mark a device ID
> table in rfkill-gpio.
> 
> Please let me know if there are problems!

Pulled, thanks John.
