From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] gianfar: xmit() improvements
Date: Wed, 24 Feb 2016 16:56:23 -0500 (EST)
Message-ID: <20160224.165623.1194419240731708681.davem@davemloft.net>
References: <1456220919-31440-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406AbcBXV4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 16:56:25 -0500
In-Reply-To: <1456220919-31440-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Tue, 23 Feb 2016 11:48:36 +0200

> Remove redundant operations, improve code locality and maintainability.
> Thanks.
> 
> V2: Updated first patch to not touch existing wmb().

Series applied, thanks.
