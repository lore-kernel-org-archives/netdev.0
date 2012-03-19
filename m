From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] Gianfar byte queue limits
Date: Mon, 19 Mar 2012 16:46:42 -0400 (EDT)
Message-ID: <20120319.164642.1200863018458579196.davem@davemloft.net>
References: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
	<1332106761-18293-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab2CSUsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 16:48:52 -0400
In-Reply-To: <1332106761-18293-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 18 Mar 2012 17:39:17 -0400

> The following changes since commit cdf485be3a63d1f34293740fb726088c6840ceea:
> 
>   ixgbe: dcb: use DCB config values for FCoE traffic class on open (2012-03-14 00:49:10 -0700)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git gianfar-bql
> 
> for you to fetch changes up to 5407b14c6792d6ff122ecb1a2a6acffad60ef389:
> 
>   gianfar: use netif_tx_queue_stopped instead of __netif_subqueue_stopped (2012-03-18 17:11:22 -0400)

Pulled, thanks.
