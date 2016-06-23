From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] qed*: coalesce parameters config support.
Date: Thu, 23 Jun 2016 15:57:50 -0400 (EDT)
Message-ID: <20160623.155750.1837453048893199493.davem@davemloft.net>
References: <1466516182-24442-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcFWT54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 15:57:56 -0400
In-Reply-To: <1466516182-24442-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Tue, 21 Jun 2016 09:36:20 -0400

> The patch series adds the support for config/read of the adapter coalesce
> parameters. Patch (1) adds the qed infrastructure/APIs for the support and
> patch (2) adds the driver support for following ethtool commands:
> 	ethtool -c|--show-coalesce ethX
> 	ethtool -C|--coalesce ethX [rx-usecs N] [tx-usecs N]

Series applied.
