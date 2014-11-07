From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next 0/5] *** Introduce 4 AD link speed ***
Date: Fri, 07 Nov 2014 15:19:18 -0500 (EST)
Message-ID: <20141107.151918.371340447814973895.davem@davemloft.net>
References: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jianhua.Xie@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbaKGUTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 15:19:21 -0500
In-Reply-To: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xie Jianhua <Jianhua.Xie@freescale.com>
Date: Thu, 6 Nov 2014 19:52:47 +0800

> From: Jianhua Xie <Jianhua.Xie@freescale.com>
> 
> User Key bits in Port key of AD mode are yet not used.  This series
> expands speed type bits and shrinks unused user Key bits in AD mode
> Port Key, introduces 4 AD link speed: 2.5G/20G/40G/56G, and fixes
> aggregated link bandwidth calculation based on new link speed.

I think you can compress patches #2 to #5 into one single patch.
