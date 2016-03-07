From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] qed/qede: Add hardware GRO support
Date: Mon, 07 Mar 2016 15:01:58 -0500 (EST)
Message-ID: <20160307.150158.1082478169494770135.davem@davemloft.net>
References: <1457112906-4307-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbcCGUCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:02:01 -0500
In-Reply-To: <1457112906-4307-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Fri, 4 Mar 2016 12:35:04 -0500

> This patch series enables hardware GRO and add support for handling
> HW aggregated TCP packets in driver receive flow by skipping
> software GRO handling in stack.
> 
> Please consider applying this series to net-next.

Series applied, thanks.
