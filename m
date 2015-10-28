From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Mellanox mlx4 driver fixes for 4.3-rc7
Date: Tue, 27 Oct 2015 20:29:59 -0700 (PDT)
Message-ID: <20151027.202959.916106486268584605.davem@davemloft.net>
References: <1445960180-3450-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbbJ1DNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 23:13:18 -0400
In-Reply-To: <1445960180-3450-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 27 Oct 2015 17:36:18 +0200

> Jack's fix is for a regression introduced in 4.3-rc1
> 
> Carol's fix addresses an issue which exists for while and 
> turns to beat us hard on PPC, please queue for -stable. 

Series applied, and patch #2 queued up for -stable.

Thanks.
