From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/2] signal reception fixes
Date: Fri, 13 May 2011 14:42:10 -0400 (EDT)
Message-ID: <20110513.144210.1419236978902923318.davem@davemloft.net>
References: <93676d63-5688-44b4-a0d0-bb06e634cdbd@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755403Ab1EMSmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 14:42:14 -0400
In-Reply-To: <93676d63-5688-44b4-a0d0-bb06e634cdbd@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 13 May 2011 11:02:14 +0530

> Incorporated Ben's comment w.r.t replacing schedule_timeout() with msleep()
> 
> Sathya Perla (2):
>   be2net: handle signal reception while waiting for POST
>   be2net: fix mbox polling for signal reception

Both applied, thanks.
