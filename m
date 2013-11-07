From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc9420: Use netif_<level>
Date: Thu, 07 Nov 2013 02:15:04 -0500 (EST)
Message-ID: <20131107.021504.523179934067535255.davem@davemloft.net>
References: <1383676461.4387.28.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab3KGHPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:15:05 -0500
In-Reply-To: <1383676461.4387.28.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 05 Nov 2013 10:34:21 -0800

> Use a more standard logging style.
> 
> Convert smsc_<level> macros to use netif_<level>.
> Remove unused #define PFX
> Add pr_fmt and neaten pr_<level> uses.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Also applied, thanks Joe.
