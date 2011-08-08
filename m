From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Add SUPPORTED_MII and SUPPORTED_Autoneg
Date: Sun, 07 Aug 2011 22:09:38 -0700 (PDT)
Message-ID: <20110807.220938.1623245893219976344.davem@davemloft.net>
References: <1312463985-2230-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbouatmailru@gmail.com
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368Ab1HHFJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:09:45 -0400
In-Reply-To: <1312463985-2230-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Thu, 4 Aug 2011 15:19:45 +0200

> The driver supports Autoneg and at least MII. Tell the PHY
> that to avoid any confusion in the PHY code.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Applied.
