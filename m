From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] sfc: Nic specific sriov functions,
 netdev_ops and sriov_configure
Date: Sun, 12 Apr 2015 20:30:02 -0400 (EDT)
Message-ID: <20150412.203002.454810061015500201.davem@davemloft.net>
References: <5527926E.7030903@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbbDMAaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 20:30:12 -0400
In-Reply-To: <5527926E.7030903@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 10 Apr 2015 10:05:50 +0100

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

Series applied.
