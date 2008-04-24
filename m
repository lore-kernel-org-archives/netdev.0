From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 2.6.25-rc8] ixgbe: save and restore pcie/msi state
 to support EEH recovery
Date: Thu, 24 Apr 2008 08:56:28 -0700 (PDT)
Message-ID: <20080424.085628.24868716.davem@davemloft.net>
References: <1207856434.24768.27.camel@wendyx.austin.ibm.com>
	<47FE7D3A.2090703@intel.com>
	<1209052206.7339.40.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org, jeff@garzik.org,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net
To: wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55869
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760034AbYDXP43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 11:56:29 -0400
In-Reply-To: <1209052206.7339.40.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wendy xiong <wendyx@us.ibm.com>
Date: Thu, 24 Apr 2008 10:50:06 -0500

> Hi David,
> 
> These two patches got ack by Intel developer. Can you put them in your
> tree for 2.6.26 kernel?

I don't take network driver patches, Jeff Garzik does.
