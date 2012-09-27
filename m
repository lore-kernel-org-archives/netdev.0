From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Add Chelsio T4 firmware configuration file support
Date: Thu, 27 Sep 2012 17:56:52 -0400 (EDT)
Message-ID: <20120927.175652.826147107679630598.davem@davemloft.net>
References: <1348663182-20190-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com, felix@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755434Ab2I0V44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 17:56:56 -0400
In-Reply-To: <1348663182-20190-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Wed, 26 Sep 2012 18:09:35 +0530

> This patch series adds aupport for firmware configuration file for Chelsio T4
> adapters.
> 
> The Firmware Configuration file was primarily developed in order to centralize
> all of the configuration, resource allocation, etc. for Unified Wire operation
> where multiple Physical / Virtual Function Drivers would be using a T4 adapter
> simultaneously.
> 
> The patch series also has bug fixes which can occur while upgrading the T4
> firmware.
> 
> The patch series is built against David Miller's net-next tree.

Series applied.
