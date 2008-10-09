From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] bnx2: Add bnx2_shutdown_chip().
Date: Thu, 09 Oct 2008 12:21:16 -0700 (PDT)
Message-ID: <20081009.122116.177343040.davem@davemloft.net>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com, mcarlson@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760867AbYJITVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 15:21:40 -0400
In-Reply-To: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu,  9 Oct 2008 10:16:03 -0700

> This logic is used in bnx2_close() and bnx2_suspend() and
> so should be separated out into a separate function.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
