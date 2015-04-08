From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sfc: Nic specific sriov functions,
 netdev_ops and sriov_configure
Date: Wed, 08 Apr 2015 12:22:20 -0400 (EDT)
Message-ID: <20150408.122220.746628120642749000.davem@davemloft.net>
References: <552539BA.6070707@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbbDHQWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:22:22 -0400
In-Reply-To: <552539BA.6070707@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 8 Apr 2015 15:22:50 +0100

> First two patches among the series of patches to support SRIOV on EF10.
> 
> First patch declares nic specific sriov functions in nic specific headers,
> creates only one instance of the netdev_ops, removes sriov functionality
> from Falcon code.
> 
> Second patch adds support for sriov_configure.
> 
> The Virtual Functions can be enabled but they do not bind to the SFC
> driver just yet.

Series applied, thanks.
