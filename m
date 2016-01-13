From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] 3c59x: Fix dma map/unmap imbalances
Date: Wed, 13 Jan 2016 14:55:58 -0500 (EST)
Message-ID: <20160113.145558.283872959731839457.davem@davemloft.net>
References: <1452707034-16379-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756084AbcAMTz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 14:55:59 -0500
In-Reply-To: <1452707034-16379-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 13 Jan 2016 12:43:52 -0500

> Hey all-
> 	recent enhancements to libdma revealed a few minor bugs in 3c59x, in
> which dma ranges were mapped as singles and unmaped as pages, or vice versa.
> These patches fix those up.  Tested by myself with success

Series applied, but there was trailing whitespace added in the second
patch which I had to fix up by hand.

Please be careful when copy&pasteing stuff. :)
