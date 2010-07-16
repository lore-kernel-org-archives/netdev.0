From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [2/5] Interrupt
 control bitmap
Date: Thu, 15 Jul 2010 22:19:02 -0700 (PDT)
Message-ID: <20100715.221902.13737987.davem@davemloft.net>
References: <alpine.LRH.2.00.1007131746370.32055@localhost.localdomain>
	<20100714.140433.59678649.davem@davemloft.net>
	<alpine.LRH.2.00.1007150121400.25472@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, ronghua@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752597Ab0GPFSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 01:18:46 -0400
In-Reply-To: <alpine.LRH.2.00.1007150121400.25472@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Thu, 15 Jul 2010 18:20:03 -0700 (PDT)

> Reposting the patch with the endianness fix.
> 
> ---
> 
> A new bit map 'intrCtrl' is introduced in the DriverShared area. The 
> driver Ashould update VMXNET3_IC_DISABLE_ALL bit before writing IMR.
> 
> Signed-off-by: Ronghua Zang <ronghua@vmware.com>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

Applied.
