From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 net-next] bnx2: Fix endian swapping on firmware
 version string
Date: Thu, 21 Jul 2011 12:47:47 -0700 (PDT)
Message-ID: <20110721.124747.1329320012557446277.davem@davemloft.net>
References: <1311209725-10414-2-git-send-email-mchan@broadcom.com>
	<1311209725-10414-3-git-send-email-mchan@broadcom.com>
	<1311209725-10414-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab1GUTrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 15:47:49 -0400
In-Reply-To: <1311209725-10414-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 20 Jul 2011 17:55:25 -0700

> so that ethtool -i will display it correctly on big endian systems.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

Applied.
