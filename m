From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] r8169: enable transmit time stamping.
Date: Sun, 11 Mar 2012 15:43:56 -0700 (PDT)
Message-ID: <20120311.154356.48308489151602706.davem@davemloft.net>
References: <cover.1331400160.git.richardcochran@gmail.com>
	<7ef0f3118d1ff0925852b31397e3bb9684e5a9fd.1331400160.git.richardcochran@gmail.com>
	<20120310222147.GA10071@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699Ab2CKWpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:45:01 -0400
In-Reply-To: <20120310222147.GA10071@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 10 Mar 2012 23:21:47 +0100

> Richard Cochran <richardcochran@gmail.com> :
>> This patch has been tested on a machine with the Realtek
>> RTL8101E/RTL8102E PCI Express Fast Ethernet controller (rev 05).
>> 
>> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
>> Cc: Francois Romieu <romieu@fr.zoreil.com>
> 
> It seems ok. It is hooked at the right place.

Applied.
