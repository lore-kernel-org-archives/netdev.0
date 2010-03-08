From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add __must_check to sk_add_backlog
Date: Mon, 08 Mar 2010 10:46:44 -0800 (PST)
Message-ID: <20100308.104644.244355068.davem@davemloft.net>
References: <1268014899-31318-1-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754115Ab0CHSqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 13:46:25 -0500
In-Reply-To: <1268014899-31318-1-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yi <yi.zhu@intel.com>
Date: Mon,  8 Mar 2010 10:21:39 +0800

> Add the "__must_check" tag to sk_add_backlog() so that any failure to
> check and drop packets will be warned about.
> 
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>

Applied.
