From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] 6lowpan fixes
Date: Sat, 01 Sep 2012 22:48:58 -0400 (EDT)
Message-ID: <20120901.224858.1302164250000326522.davem@davemloft.net>
References: <1346294341-26808-1-git-send-email-alan@signal11.us>
	<1346515027-5237-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	tony.cheneau@amnesiak.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346515027-5237-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Sat,  1 Sep 2012 11:57:05 -0400

> v3 of this patch changes skb_copy() to skb_clone() in patch #1 at the
> recommendation of Eric Dumazet
> 
> Alan Ott (2):
>   6lowpan: Make a copy of skb's delivered to 6lowpan
>   6lowpan: handle NETDEV_UNREGISTER event

All applied to net-next, thanks.
