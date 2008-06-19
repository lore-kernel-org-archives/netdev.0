From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] bnx2: Cleanup error handling in bnx2_open().
Date: Thu, 19 Jun 2008 16:44:20 -0700 (PDT)
Message-ID: <20080619.164420.47065085.davem@davemloft.net>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
	<1213835132-5698-8-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750909AbYFSXoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:44:20 -0400
In-Reply-To: <1213835132-5698-8-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 18 Jun 2008 17:25:31 -0700

> All error handling in bnx2_open() can be consolidated.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied to net-next-2.6
