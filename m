From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix unlikely usage in tcp_transmit_skb()
Date: Fri, 28 Apr 2006 15:25:51 -0700 (PDT)
Message-ID: <20060428.152551.50641016.davem@davemloft.net>
References: <Pine.LNX.4.64.0604260947040.2907@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23436
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751776AbWD1WZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 18:25:39 -0400
To: hzhong@gmail.com
In-Reply-To: <Pine.LNX.4.64.0604260947040.2907@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hua Zhong <hzhong@gmail.com>
Date: Wed, 26 Apr 2006 09:50:28 -0700 (PDT)

> [I hope this time it's OK - I'm sending from pine/Linux]

It adds an extra space in the diff lines which corrupts
the patch.

I've applied this by hand, but please try to get something
which works before providing new patches.  Just try to email
yourself a patch, then try to apply it successfully yourself.

Thanks.
