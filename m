From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: fix WOL register setup for 82599
Date: Mon, 15 Feb 2010 21:52:14 -0800 (PST)
Message-ID: <20100215.215214.132896023.davem@davemloft.net>
References: <20100211141319.25672.3041.stgit@localhost.localdomain>
	<20100211141407.25672.80739.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751811Ab0BPFv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:51:59 -0500
In-Reply-To: <20100211141407.25672.80739.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 11 Feb 2010 06:14:08 -0800

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> We need to have the WUS register set to all 1's in order for the hardware
> to be capable of ever waking up.  Set it here in the ixgbe_probe().
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
