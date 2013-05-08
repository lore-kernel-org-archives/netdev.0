From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] be2net: fixes
Date: Wed, 08 May 2013 11:59:59 -0700 (PDT)
Message-ID: <20130508.115959.1716267026828826520.davem@davemloft.net>
References: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653Ab3EHTAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 15:00:03 -0400
In-Reply-To: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 8 May 2013 17:35:46 +0530

> Pls apply.
> 
> Sathya Perla (4):
>   be2net: provision VF resources before enabling SR-IOV
>   be2net: fix payload_len value for GET_MAC_LIST cmd req
>   be2net: fix EQ from getting full while cleaning RX CQ
>   be2net: disable TX in be_close()

Series applied, thanks.
