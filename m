From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] cnic: Re-init dev->stats_addr after chip
 reset
Date: Thu, 05 Jan 2012 14:08:29 -0500 (EST)
Message-ID: <20120105.140829.2201492671275920887.davem@davemloft.net>
References: <1325715148-1371-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756374Ab2AETId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:08:33 -0500
In-Reply-To: <1325715148-1371-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 4 Jan 2012 14:12:27 -0800

> because bnx2x frees the old and allocates new memory during chip reset.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
