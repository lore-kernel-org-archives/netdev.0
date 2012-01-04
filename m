From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-01-04 #2
Date: Wed, 04 Jan 2012 14:49:23 -0500 (EST)
Message-ID: <20120104.144923.372584452455227614.davem@davemloft.net>
References: <20120104164339.GG2540@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120104164339.GG2540@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 4 Jan 2012 11:43:40 -0500

> Here are a handful of straggler wireless fixes for 3.2.  Included is
> a NULL pointer fix for mwifiex, a regression fix for handling rx
> header lengths for differnt b43 firmwares in PIO mode, a revert of
> a one-liner for Bluetooth HCI that was causing uncomfortable delays
> during resume, and an ath9k fix for a panic when running in AP mode
> with aggregation disabled.
> 
> The Bluetooth fix is a one-liner change of a delay value.  The mwifiex,
> b43, and ath9k fixes are relatively small and isolated to their
> respective drivers.
> 
> Please let me know if there are problems!
...
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Pulled, thanks.
