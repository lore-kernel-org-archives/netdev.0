From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] bnx2x: don't write dcb/llfc fields in
 STORM memory
Date: Thu, 31 Mar 2011 17:06:21 -0700 (PDT)
Message-ID: <20110331.170621.39166601.davem@davemloft.net>
References: <1301611533-9725-1-git-send-email-mchan@broadcom.com>
	<1301611533-9725-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59427
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753950Ab1DAAG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:06:59 -0400
In-Reply-To: <1301611533-9725-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 31 Mar 2011 14:45:32 -0800

> From: Dmitry Kravkov <dmitry@broadcom.com>
> 
> We could get hardware attention during DCB/FCoE traffic without this
> fix.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
