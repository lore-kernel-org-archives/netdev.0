From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-01-17
Date: Thu, 17 Jan 2013 14:50:56 -0500 (EST)
Message-ID: <20130117.145056.60689530330513006.davem@davemloft.net>
References: <20130117173239.GA2098@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130117173239.GA2098@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 17 Jan 2013 12:32:40 -0500

> This batch of fixes is intended for 3.8...
> 
> Included is a Bluetooth pull.  Gustavo says:
> 
> "A few fixes for 3.8. Five of them are just new devices ids addition.
> Apart from the that there is fix to a kernel memory leak to userspace from
> Anderson Lizardo, two interoperability fixes from Jaganath Kanakkassery and
> Szymon Janc. And a crash fix by me."
> 
> Along with that, Amitkumar Karwar brings a pair of mwifiex fixes for
> problems related to handling of band information within the driver.
> These problems can lead to association failures.
> 
> Sujith Manoharan fixes a memory leak in the ath9k_htc code (originally
> reported by Larry Finger).
> 
> The big hero this round is Felix Fietkau.  Felix gives us seven
> ath9k fixes, including a fix for a race condition, the removal of a
> double-free, and a fix for a deadlock, among others.
> 
> These have all been in linux-next for at least a couple of days,
> with no complaints so far.  Please let me know if there are problems!

Pulled, thanks John.
