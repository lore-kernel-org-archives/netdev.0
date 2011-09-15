From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mii: Remove references to DP83840 PHY in mii.h
Date: Thu, 15 Sep 2011 15:44:24 -0400 (EDT)
Message-ID: <20110915.154424.143549802650493420.davem@davemloft.net>
References: <1314804928-7353-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mark.einon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934532Ab1IOTo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 15:44:28 -0400
In-Reply-To: <1314804928-7353-1-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Einon <mark.einon@gmail.com>
Date: Wed, 31 Aug 2011 16:35:28 +0100

> There are references to this PHY chip in the generic mii.h header, so removing them.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>

Applied.
