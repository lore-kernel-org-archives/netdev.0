From: David Miller <davem@davemloft.net>
Subject: Re: [UPDATED][NET-NEXT PATCH 3/4] bnx2: Remove name field from
 bnx2 structure
Date: Thu, 18 Sep 2008 16:40:17 -0700 (PDT)
Message-ID: <20080918.164017.165476708.davem@davemloft.net>
References: <1221757033-4874-2-git-send-email-benli@broadcom.com>
	<1221757033-4874-3-git-send-email-benli@broadcom.com>
	<1221757033-4874-4-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: benli@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755501AbYIRXk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:40:29 -0400
In-Reply-To: <1221757033-4874-4-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Benjamin Li" <benli@broadcom.com>
Date: Thu, 18 Sep 2008 09:57:12 -0700

> The name of the board is only used during the initialization of
> the adapter.  We can save the space of a pointer by not storing
> this information.
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
