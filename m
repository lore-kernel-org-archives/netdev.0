From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: misc: Remove unused OOM variables
Date: Wed, 06 Feb 2013 15:02:58 -0500 (EST)
Message-ID: <20130206.150258.701602632249933551.davem@davemloft.net>
References: <51108250.mCy4M9/YF2ueqPWm%fengguang.wu@intel.com>
	<1360038149.4849.11.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-wimax@intel.com, wimax@linuxwimax.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030187Ab3BFUDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:03:00 -0500
In-Reply-To: <1360038149.4849.11.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 04 Feb 2013 20:22:29 -0800

> commits 9d11bd159
> ("wimax: Remove unnecessary alloc/OOM messages, alloc cleanups")
> and b2adaca92
> ("ethernet: Remove unnecessary alloc/OOM messages, alloc cleanups")
> added a couple of unused variable warnings.
> 
> Remove the now unused variables.
> 
> Noticed-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
