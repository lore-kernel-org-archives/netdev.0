From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-12-03
Date: Wed, 08 Dec 2010 08:14:29 -0800 (PST)
Message-ID: <20101208.081429.193694468.davem@davemloft.net>
References: <20101203201602.GE2348@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101203201602.GE2348@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 3 Dec 2010 15:16:02 -0500

> This is a batch of fixes intended for 2.6.37.  There are a number of
> small fixes that speak for themselves.  Also included are a small patch
> for ar9170 to advertise Wi-Fi Peer-to-peer capability -- not truly a
> fix, but helpful for those developing the related userland bits and
> harmless to everyone else.  There are also some endian related patches
> for ath9k from Felix that are a bit large, but they mostly just refactor
> some tables in order to fix an endian problem that can result in invalid
> regulatory settings on some boxes.
> 
> Also includes are some Bluetooth patches via Gustavo Padovan:
> 
> "Here goes 3 simple patches intended to 2.6.37. First one is from myself
> and fix some trivial return values. Then we also have a fix from Stefan
> Seyfried on btusb to avoid emitting an err when we USB is autosupended.
> Last, a patch from Bala Shanmugam that fix the firmware loading process
> for the ath3k driver."
> 
> Please let me know if there are problems!

Pulled, thanks John.
