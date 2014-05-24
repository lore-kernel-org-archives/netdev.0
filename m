From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-05-23
Date: Sat, 24 May 2014 14:06:45 -0400 (EDT)
Message-ID: <20140524.140645.430202997634061971.davem@davemloft.net>
References: <20140523150733.GC13311@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140523150733.GC13311@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 23 May 2014 11:07:34 -0400

> I have two more fixes intended for the 3.15 stream...
> 
> For the iwlwifi one, Emmanuel says:
> 
> "A race has been discovered in the beacon filtering code. Since the
> fix is too big for 3.15, I disable here the feature."
> 
> For the bluetooth one, Gustavo says:
> 
> "This pull request contains a very important fix for 3.15. Here we fix the
> permissions of a debugfs file that would otherwise allow unauthorized users
> to write content to it."
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
