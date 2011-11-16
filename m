From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Move #include of module.h
Date: Wed, 16 Nov 2011 17:49:04 -0500 (EST)
Message-ID: <20111116.174904.1982057453454814261.davem@davemloft.net>
References: <20111115.183808.2066749950387258221.davem@davemloft.net>
	<20111115155210.69249eb9.akpm@linux-foundation.org>
	<1321401374.21286.22.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, tomoya-linux@dsn.okisemi.com,
	toshiharu-linux@dsn.okisemi.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab1KPWtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:49:13 -0500
In-Reply-To: <1321401374.21286.22.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 15 Nov 2011 15:56:14 -0800

> The first #include must be pch_gbe.h as it
> does a #define of pr_fmt.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
