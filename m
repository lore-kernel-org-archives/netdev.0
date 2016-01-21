From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tg3: update on maintainer and fix for tx
 timeout
Date: Wed, 20 Jan 2016 18:59:02 -0800 (PST)
Message-ID: <20160120.185902.462661342854221917.davem@davemloft.net>
References: <1453290418-15331-1-git-send-email-siva.kallam@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, prashant@broadcom.com
To: siva.kallam@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965425AbcAUC7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:59:03 -0500
In-Reply-To: <1453290418-15331-1-git-send-email-siva.kallam@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: skallam <siva.kallam@broadcom.com>
Date: Wed, 20 Jan 2016 17:16:56 +0530

> From: Siva Reddy Kallam <siva.kallam@broadcom.com>
> 
> First patch:
> 	This patch includes additional maintainer for tg3
> 
> Second patch:
> 	Fix for tg3 transmit queue 0 timed out when too many gso_segs

Why are you targetting bug fixes at the 'net-next' tree?
