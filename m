From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bonding: implement bond_poll_controller()
Date: Fri, 06 Mar 2015 14:41:15 -0500 (EST)
Message-ID: <20150306.144115.1556972834102683499.davem@davemloft.net>
References: <1425535072-23068-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833AbbCFTlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 14:41:18 -0500
In-Reply-To: <1425535072-23068-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed,  4 Mar 2015 21:57:52 -0800

> This patches implements the poll_controller support for all
> bonding driver. If the slaves have poll_controller net_op defined,
> this implementation calls them. This is mode agnostic implementation
> and iterates through all slaves (based on mode) and calls respective
> handler.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
