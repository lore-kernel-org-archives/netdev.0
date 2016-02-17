From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] sctp: some cleanups for sctp
Date: Wed, 17 Feb 2016 15:42:31 -0500 (EST)
Message-ID: <20160217.154231.1059835157683583160.davem@davemloft.net>
References: <cover.1455517541.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964970AbcBQUme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 15:42:34 -0500
In-Reply-To: <cover.1455517541.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Mon, 15 Feb 2016 14:28:02 +0800

> There are some unused function and redundant rcu locks should be
> removed.

Series applied to net-next, please target cleanups to the appropriate
tree in the future.

Also, please respond to Neil Horman's query about the use of BH
RCU locking wrt. patch #1.

Thanks.
