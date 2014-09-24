From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-09-23
Date: Wed, 24 Sep 2014 15:01:29 -0400 (EDT)
Message-ID: <20140924.150129.1615102185939385229.davem@davemloft.net>
References: <20140923150002.GH23806@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140923150002.GH23806@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 23 Sep 2014 11:00:02 -0400

> Please consider pulling this one last batch of fixes intended for the 3.17 stream!
> 
> For the NFC bits, Samuel says:
> 
> "Hopefully not too late for a handful of NFC fixes:
> 
> - 2 potential build failures for ST21NFCA and ST21NFCB, triggered by a
>   depmod dependenyc cycle.
> - One potential buffer overflow in the microread driver."
> 
> On top of that...
> 
> Emil Goode provides a fix for a brcmfmac off-by-one regression which
> was introduced in the 3.17 cycle.
> 
> Loic Poulain fixes a polarity mismatch for a variable assignment
> inside of rfkill-gpio.
> 
> Wojciech Dubowik prevents a NULL pointer dereference in ath9k.
> 
> Please let me know if there are problems!

Pulled, thanks John.
