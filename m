From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vlan: add 802.1q netpoll support
Date: Thu, 08 Dec 2011 19:55:22 -0500 (EST)
Message-ID: <20111208.195522.760822966632745223.davem@davemloft.net>
References: <20111208.000730.63159506168958262.davem@davemloft.net>
	<20111208153558.GE30652@kvack.org>
	<20111208162049.GF30652@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab1LIAzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 19:55:25 -0500
In-Reply-To: <20111208162049.GF30652@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Thu, 8 Dec 2011 11:20:49 -0500

> [PATCH net-next v2] vlan: add 802.1q netpoll support
> 
> Add netpoll support to 802.1q vlan devices.  Based on the netpoll support
> in the bridging code.  Tested on a forced_eth device with netconsole.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org> 

Applied.
