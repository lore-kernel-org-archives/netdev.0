From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ucc_geth: allow to set mac address on running
 device
Date: Tue, 26 May 2009 20:49:11 -0700 (PDT)
Message-ID: <20090526.204911.75347876.davem@davemloft.net>
References: <1243388936.13410.4.camel@kevin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, leoli@freescale.com
To: kexin.hao@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41001
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755691AbZE0DtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:49:12 -0400
In-Reply-To: <1243388936.13410.4.camel@kevin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hao <kexin.hao@windriver.com>
Date: Wed, 27 May 2009 09:48:56 +0800

> Inspired by the patch for 8139too (bda6a15a).
> 
> Currently we can't set mac address on a running ucc_geth device.
> But this is needed when you use this device as a bonding slave in
> bonding device in balance-alb mode. So add this feature for ucc_geth
> device.
> 
> Signed-off-by: Kevin Hao <kexin.hao@windriver.com>

Applied to net-next-2.6, thanks.
