From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/10] ixgbe: Update get_physical_layer() calls, plus a
 version bump
Date: Sat, 11 Apr 2009 02:51:26 -0700 (PDT)
Message-ID: <20090411.025126.180213633.davem@davemloft.net>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
	<20090410082850.14372.91271.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757656AbZDKJvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:51:36 -0400
In-Reply-To: <20090410082850.14372.91271.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2009 01:28:50 -0700

> Not all physical connection types are being correctly identified.  This
> fixes that issue, and cleans up the logic to make it more maintainable.
> 
> Also clean up the code for device capabilities from the EEPROM to support
> multiple SKUs of the same hardware.
> 
> Bump the version to reflect all the updates since the 82599 merge.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
