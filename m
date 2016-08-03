From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] tg3: Disallow 0 rx coalesce time and correctly
 report RSS queues in tg3_get_rxnfc
Date: Wed, 03 Aug 2016 11:56:45 -0700 (PDT)
Message-ID: <20160803.115645.2266573771021836487.davem@davemloft.net>
References: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
	prashant@broadcom.com, satish.baddipadige@broadcom.com
To: siva.kallam@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995AbcHCS6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 14:58:11 -0400
In-Reply-To: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: skallam <siva.kallam@broadcom.com>
Date: Wed,  3 Aug 2016 09:43:58 +0530

> First patch:
>         Diasllow rx coalescing time to be 0
> 
> Second patch:
>         Report the correct number of RSS queues through tg3_get_rxnfc

Series applied, thanks.
