From: David Miller <davem@davemloft.net>
Subject: Re: [UPDATED][NET-NEXT PATCH 4/4] bnx2: Remove timer_interval
 field from the bnx2 structure
Date: Thu, 18 Sep 2008 16:40:58 -0700 (PDT)
Message-ID: <20080918.164058.43305872.davem@davemloft.net>
References: <1221757033-4874-3-git-send-email-benli@broadcom.com>
	<1221757033-4874-4-git-send-email-benli@broadcom.com>
	<1221757033-4874-5-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: benli@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755221AbYIRXlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:41:11 -0400
In-Reply-To: <1221757033-4874-5-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Benjamin Li" <benli@broadcom.com>
Date: Thu, 18 Sep 2008 09:57:13 -0700

> The timer_interval field is only assigned once, and never reassigned.
> We can safely replace all instances of the timer_interval with a
> constant value.
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Also applied, thanks.
