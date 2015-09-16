From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix cdc-phonet.c dependency and build
 error
Date: Wed, 16 Sep 2015 11:51:34 -0700 (PDT)
Message-ID: <20150916.115134.1177033076495078606.davem@davemloft.net>
References: <55F9B5C9.1060509@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbbIPTLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 15:11:12 -0400
In-Reply-To: <55F9B5C9.1060509@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Wed, 16 Sep 2015 11:32:41 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix build error caused by missing Kconfig dependency:
> 
> ERROR: "cdc_parse_cdc_header" [drivers/net/usb/cdc-phonet.ko] undefined!
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
