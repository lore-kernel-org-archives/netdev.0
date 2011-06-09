From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5 net-next] cnic: Randomize initial TCP port for
 iSCSI connections
Date: Wed, 08 Jun 2011 23:53:13 -0700 (PDT)
Message-ID: <20110608.235313.871483431487331905.davem@davemloft.net>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
	<1307597376-5379-2-git-send-email-mchan@broadcom.com>
	<1307597376-5379-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eddie.wai@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569Ab1FIGxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:53:14 -0400
In-Reply-To: <1307597376-5379-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 8 Jun 2011 22:29:34 -0700

> From: Eddie Wai <eddie.wai@broadcom.com>
> 
> This reduces the likelihood of port re-use when re-loading the driver.
> 
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
