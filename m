From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: Allow tx itr specific settings
Date: Mon, 21 Sep 2009 22:37:43 -0700 (PDT)
Message-ID: <20090921.223743.17304011.davem@davemloft.net>
References: <20090918194533.28898.49436.stgit@localhost.localdomain>
	<20090918194606.28898.37888.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, shannon.nelson@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754885AbZIVFhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 01:37:25 -0400
In-Reply-To: <20090918194606.28898.37888.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 18 Sep 2009 12:46:06 -0700

> From: Nelson, Shannon <shannon.nelson@intel.com>
> 
> Allow the user to set Tx specific itr values.  This only makes sense
> when there are separate vectors for Tx and Rx.  When the queues are
> doubled up RxTx on the vectors, we still only use the rx itr value.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
