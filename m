From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bonding: handle case of device named bonding_master
Date: Wed, 14 May 2008 22:35:16 -0700 (PDT)
Message-ID: <20080514.223516.71667347.davem@davemloft.net>
References: <20080514170316.672f809d@extreme>
	<20080514181257.74fbb5aa@extreme>
	<20080514181528.1ff1791a@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36415
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751184AbYEOFfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 01:35:21 -0400
In-Reply-To: <20080514181528.1ff1791a@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 14 May 2008 18:15:28 -0700

> If device already exists named bonding_masters, then fail. This is a wierd
> corner case only a QA group could love.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Also applied, thanks a lot Stephen.
