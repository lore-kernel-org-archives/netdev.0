From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/6] sctp: support sctp_diag in kernel
Date: Fri, 15 Apr 2016 17:30:25 -0400 (EDT)
Message-ID: <20160415.173025.576682964050812112.davem@davemloft.net>
References: <cover.1460618169.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbcDOVa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 17:30:27 -0400
In-Reply-To: <cover.1460618169.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 14 Apr 2016 15:35:29 +0800

> This patchset will add sctp_diag module to implement diag interface on
> sctp in kernel.
 ...

Looks good to me, series applied, thanks.

Please follow up on the suggestion to use jiffies_to_ms(), thanks.
