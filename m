From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 5/7] ixgbe: fix ixgbe_tx_is_paused logic
Date: Tue, 18 May 2010 19:44:54 -0700 (PDT)
Message-ID: <20100518.194454.171482194.davem@davemloft.net>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
	<20100519020010.18654.48130.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754272Ab0ESCoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:44:46 -0400
In-Reply-To: <20100519020010.18654.48130.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 May 2010 19:00:10 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> The TFCS bits show the current XON state.  Meaning that the
> device is paused if these bits are 0.  This fixes the logic
> to work as it was intended.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
