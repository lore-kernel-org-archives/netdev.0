From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bna: make function tables cont
Date: Fri, 16 Sep 2011 19:20:47 -0400 (EDT)
Message-ID: <20110916.192047.600147576827059420.davem@davemloft.net>
References: <20110916140951.6318785d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab1IPXVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 19:21:50 -0400
In-Reply-To: <20110916140951.6318785d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 16 Sep 2011 14:09:51 -0700

> To prevent malicious usage, all tables of pointers must be const.
> 
> Compile tested only.
> Gleaned for PAX.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
