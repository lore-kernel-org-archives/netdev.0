From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4][net-next] gianfar: Address napi polling issues
Date: Wed, 20 Mar 2013 13:22:31 -0400 (EDT)
Message-ID: <20130320.132231.783609445071482945.davem@davemloft.net>
References: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3CTRWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:22:33 -0400
In-Reply-To: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Tue, 19 Mar 2013 19:40:01 +0200

> Hello David, Paul,
> 
> These patches take on several issues in the current napi polling
> routine, affecting mostly the newer Multi Queue Multi Group
> (MQ_MG_MODE) devices. Seems that the code for these devices
> has been neglected.
> 
> Tested on p1010 (single core, multi q), p1020 (dual core, multi q)
> and p2020 (dual core, single q mode).

All applied, thanks.
