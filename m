From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/4] Mellanox driver update, Oct 14 2015
Date: Wed, 14 Oct 2015 19:15:11 -0700 (PDT)
Message-ID: <20151014.191511.395802773815194353.davem@davemloft.net>
References: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eli@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932406AbbJOB7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:59:05 -0400
In-Reply-To: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 14 Oct 2015 17:43:44 +0300

> Hi Dave,
> 
> This series contains two more patches from Eli, patch from Majd
> to support PCI error handlers and a fix from Jack to mlx4 VFs
> when probed without a provisioned mac address.
> 
> The patch set applied on top of net-next commit bbb300e "Merge branch 'bridge-vlan'"
> 
> changes from V0:
>   - made the health flag int --> bool to address comment from Dave on patch #1
>   - fixed sparse warning noted by the 0-day build tests in patch #2

Series applied, thanks.
