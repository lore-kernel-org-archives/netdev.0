From: David Miller <davem@davemloft.net>
Subject: Re: [trivial PATCH resend 2/2] ixgbe: use PCI_VENDOR_ID_INTEL
Date: Fri, 20 Jul 2012 11:00:16 -0700 (PDT)
Message-ID: <20120720.110016.609361522203455911.davem@davemloft.net>
References: <1342767729-17788-1-git-send-email-jdmason@kudzu.us>
	<1342767729-17788-3-git-send-email-jdmason@kudzu.us>
	<1342768629.2616.27.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, trivial@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab2GTSAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:00:17 -0400
In-Reply-To: <1342768629.2616.27.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 20 Jul 2012 00:17:09 -0700

> On Fri, 2012-07-20 at 00:02 -0700, Jon Mason wrote:
>> Use PCI_VENDOR_ID_INTEL from pci_ids.h instead of creating its own
>> vendor ID #define.
>> 
>> Signed-off-by: Jon Mason <jdmason@kudzu.us>
...
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
