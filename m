From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/8] enic updates
Date: Mon, 23 Jun 2014 14:40:53 -0700 (PDT)
Message-ID: <20140623.144053.1693421076211239015.davem@davemloft.net>
References: <1403519885-4908-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbaFWVk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 17:40:57 -0400
In-Reply-To: <1403519885-4908-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Mon, 23 Jun 2014 16:07:57 +0530

> This series fixes minor bugs and adds new features like Accelerated RFS,
> busy_poll, tx clean-up in napi_poll.
 ...
> v3:
> * While doing tx cleanup in napi, ignore budget and clean up all desc possible.
> 
> v2:
> * Fix #ifdef coding style issue in '[PATCH 4/8] enic: alloc/free rx_cpu_rmap'
>   And [PATCH 5/8] enic: Add Accelerated RFS support'

Series applied, thanks.
