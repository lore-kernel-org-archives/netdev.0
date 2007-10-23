From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7]
 pci: Export the pci_restore_msi_state() function
Date: Mon, 22 Oct 2007 17:23:32 -0700 (PDT)
Message-ID: <20071022.172332.112621497.davem@davemloft.net>
References: <20071020004610.GR29903@austin.ibm.com>
	<20071019.175308.54212640.davem@davemloft.net>
	<20071022195451.GE4280@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, mchan@broadcom.com, mcarlson@broadcom.com,
	netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	michael@ellerman.id.au
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60527
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750905AbXJWAXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 20:23:10 -0400
In-Reply-To: <20071022195451.GE4280@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Mon, 22 Oct 2007 14:54:52 -0500

> As discussed in the other thread, I'll try to set up a patch
> for an arch callback for restoring msi state.

Thank you.
