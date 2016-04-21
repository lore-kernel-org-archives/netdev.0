From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] Mellaox 40G driver fixes for 4.6-rc
Date: Thu, 21 Apr 2016 15:03:00 -0400 (EDT)
Message-ID: <20160421.150300.277638880735915386.davem@davemloft.net>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, yishaih@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbcDUTDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:03:02 -0400
In-Reply-To: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 20 Apr 2016 16:01:14 +0300

> With the fix for ARM bug being under the works, these are 
> few other fixes for mlx4 we have ready to go.
> 
> Eran addressed the problematic/wrong reporting of dropped packets, Daniel 
> fixed some matters related to PPC EEH's and Jenny's patch makes sure
> VFs can't change the port's pause settings.

Series applied, thanks.
