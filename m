From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] 6lowpan default hardware address
Date: Tue, 08 Oct 2013 15:29:11 -0400 (EDT)
Message-ID: <20131008.152911.2206663013355897986.davem@davemloft.net>
References: <1381029319-6835-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	alex.aring@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381029319-6835-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Sat,  5 Oct 2013 23:15:17 -0400

> Alexander Aring suggested that devices desired to be linked to 6lowpan
> be checked for actually being of type IEEE802154, since IEEE802154 devices
> are all that are supported by 6lowpan at present.
> 
> Alan Ott (2):
>   6lowpan: Only make 6lowpan links to IEEE802154 devices
>   6lowpan: Sync default hardware address of lowpan links to their wpan

Series applied, thanks Alan.
