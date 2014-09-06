From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix link problems for 1G SFP RJ45 module
Date: Fri, 05 Sep 2014 17:28:47 -0700 (PDT)
Message-ID: <20140905.172847.66464467156986422.davem@davemloft.net>
References: <1409826360-32534-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yaniv.Rosner@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbaIFA2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:28:48 -0400
In-Reply-To: <1409826360-32534-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 4 Sep 2014 13:26:00 +0300

> From: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
> 
> When 1G SFP RJ45 module is detected, driver must reset the Tx laser
> in order to prevent link issues. As part of change, the link_attr_sync
> was relocated from vars to params.
> 
> Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
