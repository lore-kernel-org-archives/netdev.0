From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix bug with vlan strip in promsic mode
Date: Tue, 13 Apr 2010 01:57:12 -0700 (PDT)
Message-ID: <20100413.015712.170118694.davem@davemloft.net>
References: <20100325213428.8089.1879.stgit@localhost.localdomain>
	<20100326.210052.169199791.davem@davemloft.net>
	<1271108409.23823.0.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751726Ab0DMI5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:57:08 -0400
In-Reply-To: <1271108409.23823.0.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 12 Apr 2010 14:40:09 -0700

> On Fri, 2010-03-26 at 22:00 -0600, David Miller wrote:
>> Doesn't apply.
>> 
>> It depends upon the mc_list traversal conversions which are
>> absolutely not appropriate for net-2.6, and thus I only
>> applied to net-next-2.6
> 
> 	I am not seeing this patch in your net-next tree.

Even stranger I can't even find it in patchwork either.

> Do you want me to re-submit the patch against net-next?

Please resubmit, thanks Jeff.

Sorry for this.
