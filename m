From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ptp_pch: eliminate a number of sparse warnings
Date: Wed, 27 Mar 2013 13:07:19 -0400 (EDT)
Message-ID: <20130327.130719.1545669883064047427.davem@davemloft.net>
References: <1364360843-6777-1-git-send-email-kpark3469@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, keun-o.park@windriver.com,
	netdev@vger.kernel.org
To: kpark3469@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595Ab3C0RHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:07:21 -0400
In-Reply-To: <1364360843-6777-1-git-send-email-kpark3469@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kpark3469@gmail.com
Date: Wed, 27 Mar 2013 14:07:23 +0900

> From: Sahara <keun-o.park@windriver.com>
> 
> This fixes a number of sparse warnings like:
>   warning: incorrect type in argument 2 (different address spaces)
>     expected void volatile [noderef] <asn:2>*addr
>     got unsigned int *<noident>
> 
>   warning: Using plain integer as NULL pointer
> 
> Additionally this fixes a warning from checkpatch.pl like:
>   WARNING: sizeof pch_param.station should be sizeof(pch_param.station)
> 
> Signed-off-by: Sahara <keun-o.park@windriver.com>

Applied.
