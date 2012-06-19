From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 01/14] Add Default
Date: Tue, 19 Jun 2012 14:26:04 -0700 (PDT)
Message-ID: <20120619.142604.1446599238444016500.davem@davemloft.net>
References: <4FE0AABE.4070100@intel.com>
	<1340127678.2486.18.camel@lb-tlvb-eilong.il.broadcom.com>
	<4FE0CCA2.304@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, yuvalmin@broadcom.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab2FSV0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:26:05 -0400
In-Reply-To: <4FE0CCA2.304@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 19 Jun 2012 12:01:54 -0700

> There is a huge difference between a kernel parameter an a kconfig
> value.  The main idea behind the kconfig value is that you are going to
> have different preferences depending on architectures and such so it
> would make much more sense to have the default as a config option.

I don't think the issue of how many queues to use in a network driver
when you have 1024 cpus is architecture specific.

Please drop this idea, thanks.
