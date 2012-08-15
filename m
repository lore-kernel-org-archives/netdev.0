From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-08-14
Date: Tue, 14 Aug 2012 17:04:06 -0700 (PDT)
Message-ID: <20120814.170406.477984164150450996.davem@davemloft.net>
References: <20120814190245.GA22136@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814190245.GA22136@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 14 Aug 2012 15:02:46 -0400

> Alexey Khoroshilov provides a potential memory leak in rndis_wlan.
> 
> Bob Copeland gives us an ath5k fix for a lockdep problem.
> 
> Dan Carpenter fixes a signedness mismatch in at76c50x.
> 
> Felix Fietkau corrects a regression caused by an earlier commit that can
> lead to an IRQ storm.
> 
> Lorenzo Bianconi offers a fix for a bad variable initialization in ath9k
> that can cause it to improperly mark decrypted frames.
> 
> Rajkumar Manoharan fixes ath9k to prevent the btcoex time from running
> when the hardware is asleep.
> 
> The remainder are Bluetooth fixes, about which Gustavo says:
> 
> 	"Here goes some fixes for 3.6-rc1, there are a few fix to
> 	thte inquiry code by Ram Malovany, support for 2 new devices,
> 	and few others fixes for NULL dereference, possible deadlock
> 	and a memory leak."
> 
> Please let me know if there are problems!

Pulled, thanks John.
