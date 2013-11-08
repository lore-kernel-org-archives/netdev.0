From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] ixgbe: macvlan fixes
Date: Fri, 08 Nov 2013 15:21:48 -0500 (EST)
Message-ID: <20131108.152148.475567353347933697.davem@davemloft.net>
References: <20131108084654.6935.36501.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	nhorman@tuxdriver.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab3KHUVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:21:50 -0500
In-Reply-To: <20131108084654.6935.36501.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 08 Nov 2013 00:50:07 -0800

> Two additional fixes for ixgbe l2 forwarding acceleration. One
> was reported by kbuild build bot and the second after hardening
> my test scripts.
> 
> Typically I would send ixgbe fixes through JeffK's tree but I
> know a few people who are looking at the feature in their setup's 
> so wanted to be sure the patches were visible.
> 
> For reference the ixgbe accelerated macvlan patch is here:
> 
> commit 2a47fa45d4dfbc54659d28de311a1f764b296a3c
> Author: John Fastabend <john.r.fastabend@intel.com>
> Date:   Wed Nov 6 09:54:52 2013 -0800
> 
>     ixgbe: enable l2 forwarding acceleration for macvlans

Both applied, thanks John.
