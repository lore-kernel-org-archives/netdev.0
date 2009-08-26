From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/4] netxen: implement generic pcie semaphore
 functions
Date: Wed, 26 Aug 2009 15:37:47 -0700 (PDT)
Message-ID: <20090826.153747.266210126.davem@davemloft.net>
References: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
	<1251177808-16450-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751626AbZHZWhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 18:37:33 -0400
In-Reply-To: <1251177808-16450-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Mon, 24 Aug 2009 22:23:26 -0700

> Implement common function for locking/unlocking 8 hardware
> semaphores used for serializing access to shared resouces
> on a NIC board by different PCI functions.
> 
> As by definition, callers of these semaphore API can be
> put to sleep till the semaphore is locked.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
