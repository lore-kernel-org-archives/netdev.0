From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] bnx2x, cnic: Disable iSCSI if DCBX
 negotiation is successful
Date: Thu, 31 Mar 2011 17:06:27 -0700 (PDT)
Message-ID: <20110331.170627.59664194.davem@davemloft.net>
References: <1301611533-9725-1-git-send-email-mchan@broadcom.com>
	<1301611533-9725-2-git-send-email-mchan@broadcom.com>
	<1301611533-9725-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759481Ab1DAAHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:07:04 -0400
In-Reply-To: <1301611533-9725-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 31 Mar 2011 14:45:33 -0800

> From: Dmitry Kravkov <dmitry@broadcom.com>
> 
> With current bnx2x firmware 6.2.9, iSCSI is not supported in DCB
> network, so we need to disable it.  Add cnic command to disconnect
> iSCSI connections and prevent future connections when DCBX negotiation
> succeeds.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
