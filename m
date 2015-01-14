From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3 v2]tg3: synchronize_irq() should be called
 without taking locks
Date: Wed, 14 Jan 2015 17:06:20 -0500 (EST)
Message-ID: <20150114.170620.837600623688098726.davem@davemloft.net>
References: <1421263992-23907-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	peter@hurleysoftware.com
To: prashant@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbbANWGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 17:06:23 -0500
In-Reply-To: <1421263992-23907-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>
Date: Wed, 14 Jan 2015 11:33:12 -0800

> v2: Added Reported-by, Tested-by fields and reference to the thread that
>     reported the problem
> 
> This series addresses the problem reported by Peter Hurley in mail thread
> https://lkml.org/lkml/2015/1/12/1082

Series applied, thanks.
