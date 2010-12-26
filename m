From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] bna: Update Brocade BNA Ethernet driver to
 v2.3.2.3
Date: Sat, 25 Dec 2010 19:18:13 -0800 (PST)
Message-ID: <20101225.191813.193696521.davem@davemloft.net>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751471Ab0LZDRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 22:17:43 -0500
In-Reply-To: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 21 Dec 2010 23:23:06 -0800

> The following patch set updates the Brocade BNA driver to v2.3.2.3.
> 
> The patches are generated, compiled and tested against net-next-2.6 (2.6.37-rc1).
> 
> Rasesh Mody (10):
>   bna: TxRx and datapath fix
>   bna: Port enable disable sync and txq priority fix
>   bna: Fix ethtool register dump and reordered an API
>   bna: Enable pure priority tagged packet reception and rxf uninit
>     cleanup fix
>   bna: Fix for TX queue
>   bna: IOC uninit check and misc cleanup
>   bna: Removed unused code
>   bna: Restore VLAN filter table
>   bna: IOC failure auto recovery fix
>   bna: Update the driver version to 2.3.2.3

All applied, thanks.
