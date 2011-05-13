From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next-2.6 2/3] qlcnic: Take FW dump via ethtool
Date: Fri, 13 May 2011 14:44:36 -0400 (EDT)
Message-ID: <20110513.144436.1278921446519175583.davem@davemloft.net>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
	<1305240515-29237-4-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab1EMSon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 14:44:43 -0400
In-Reply-To: <1305240515-29237-4-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Thu, 12 May 2011 15:48:34 -0700

> Driver checks if the previous dump has been cleared before taking the dump.
> It doesn't take the dump if it is not cleared.
> 
> Changes from v2:
> Added lock to protect dump data structures from being mangled while
> dumping or setting them via ethtool.
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.
