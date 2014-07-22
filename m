From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] Display classifier filters using
 ethtool
Date: Mon, 21 Jul 2014 20:23:07 -0700 (PDT)
Message-ID: <20140721.202307.1630620798149459211.davem@davemloft.net>
References: <1405943538-3086-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbaGVDhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 23:37:05 -0400
In-Reply-To: <1405943538-3086-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Mon, 21 Jul 2014 17:22:16 +0530

> This series adds ethtool support to show classifier filters added by driver.
> 
> v2:
> The patch 1/2 removes the $ifdef's around the filter structure. Making it
> available always. So that .get_rxnfc() can be implimented without any #ifdefs
> 
> Please apply this to net-next.

Series applied, thanks.
