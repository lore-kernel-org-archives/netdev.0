From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/77] atm: convert mpc device to using netdev_ops
Date: Sat, 21 Mar 2009 19:34:10 -0700 (PDT)
Message-ID: <20090321.193410.156302189.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053712.648437543@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45533
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751280AbZCVCeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:34:23 -0400
In-Reply-To: <20090321053712.648437543@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:35:28 -0700

> This converts the mpc device to using new netdevice_ops.
> Compile tested only, needs more than usual review since
> device was swaping pointers around etc.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
