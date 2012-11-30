From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] mac802154: fix memory leaks
Date: Fri, 30 Nov 2012 12:19:45 -0500 (EST)
Message-ID: <20121130.121945.864836538467511517.davem@davemloft.net>
References: <504EA95C.9010003@signal11.us>
	<1354249511-8086-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	eric.dumazet@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354249511-8086-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Thu, 29 Nov 2012 23:25:10 -0500

> kfree_skb() was not getting called in the case of some failures.
> This was pointed out by Eric Dumazet.
> 
> Signed-off-by: Alan Ott <alan@signal11.us>

Applied.
