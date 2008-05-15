From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: handle errors from device_rename
Date: Wed, 14 May 2008 22:33:49 -0700 (PDT)
Message-ID: <20080514.223349.160084292.davem@davemloft.net>
References: <20080514170316.672f809d@extreme>
	<20080514181543.744b8286@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36403
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751020AbYEOFdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 01:33:54 -0400
In-Reply-To: <20080514181543.744b8286@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 14 May 2008 18:15:43 -0700

> device_rename can fail with -EEXIST or -ENOMEM, so handle any problems.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
