From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576
 virtual functions
Date: Wed, 25 Mar 2009 20:33:50 -0700 (PDT)
Message-ID: <20090325.203350.213208960.davem@davemloft.net>
References: <49CAD25F.4080705@intel.com>
	<20090325.201219.98810772.davem@davemloft.net>
	<ada4oxhufyz.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, shemminger@vyatta.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54251
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753895AbZCZDeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 23:34:02 -0400
In-Reply-To: <ada4oxhufyz.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 25 Mar 2009 20:21:08 -0700

> The igbvf driver doesn't proliferate any mistake.  The num_vfs sysfs
> attribute that everyone finds so objectionable is in the igb driver, and
> if you follow the patchwork URL that was provided, you would see that
> you applied the patch adding it back in February.  The only thing the
> igbvf driver does relating to this is bind to the PCI ID of the virtual
> functions created by the igb driver.

I am saying I made a mistake when merging that.

Can we continue forward now?

Thanks.
