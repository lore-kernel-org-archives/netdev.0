From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: avoid to repeatedly declare external
 variables
Date: Wed, 25 Mar 2015 11:40:28 -0400 (EDT)
Message-ID: <20150325.114028.1624482306623003953.davem@davemloft.net>
References: <1427263981-8348-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485AbbCYPkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:40:32 -0400
In-Reply-To: <1427263981-8348-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 25 Mar 2015 14:13:01 +0800

> Move the declaration for external variables to sctp.h file avoiding
> to repeatedly declare them with extern keyword.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied.
