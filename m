From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] etherdevice: fix comments
Date: Thu, 17 May 2012 15:37:05 -0400 (EDT)
Message-ID: <20120517.153705.942730819217312916.davem@davemloft.net>
References: <20120517081728.54719129@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760963Ab2EQThH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 15:37:07 -0400
In-Reply-To: <20120517081728.54719129@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 17 May 2012 08:17:28 -0700

> Fix some minor problems in comments of etherdevice.h
>  * Warning is out dated, file hasn't moved or disappeared in many years and
>     is unlikely to do so soon.
>  * Capitalize Ethernet consistently since it is a proper name
>  * Fix descriptive comment of padding
>  * Spelling and grammar fix for alignment comment
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
