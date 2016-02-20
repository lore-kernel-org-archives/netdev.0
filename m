From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bnxt_en: Phy related fixes.
Date: Fri, 19 Feb 2016 23:40:07 -0500 (EST)
Message-ID: <20160219.234007.59680380627387701.davem@davemloft.net>
References: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948605AbcBTEkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 23:40:09 -0500
In-Reply-To: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Fri, 19 Feb 2016 19:43:18 -0500

> 3 small patches to fix PHY related code.

Series applied, thanks Michael.

Although I'm not so sure how wise it is to not fail an ->open()
if the PHY settings fail.....
