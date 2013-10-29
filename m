From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net/benet: Make lancer_wait_ready() static
Date: Tue, 29 Oct 2013 17:50:35 -0400 (EDT)
Message-ID: <20131029.175035.654901396599489631.davem@davemloft.net>
References: <1383039057-28164-1-git-send-email-shangw@linux.vnet.ibm.com>
	<1383039057-28164-2-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sathya.Perla@emulex.com
To: shangw@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351Ab3J2Vug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 17:50:36 -0400
In-Reply-To: <1383039057-28164-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <shangw@linux.vnet.ibm.com>
Date: Tue, 29 Oct 2013 17:30:57 +0800

> The function needn't to be public, so to make it as static.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Applied.
