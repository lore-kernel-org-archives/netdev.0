From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/77] irda: net_device_ops ioctl fix
Date: Sat, 21 Mar 2009 19:34:24 -0700 (PDT)
Message-ID: <20090321.193424.52348423.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053713.012084771@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45561
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752914AbZCVCeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:34:37 -0400
In-Reply-To: <20090321053713.012084771@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Mar 2009 22:35:33 -0700

> Need to reference net_device_ops not old pointer.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
