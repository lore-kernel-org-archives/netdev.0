From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: Avoid double free of skb in tx path
Date: Sun, 05 Jun 2011 14:18:41 -0700 (PDT)
Message-ID: <20110605.141841.2230503916677883792.davem@davemloft.net>
References: <1307116338-1686-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	sucheta.chakraborty@qlogic.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756039Ab1FEVSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:18:47 -0400
In-Reply-To: <1307116338-1686-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Fri,  3 Jun 2011 08:52:18 -0700

> From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> 
> buffer->skb should be marked NULL to avoid double free of the skb.
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.
