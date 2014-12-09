From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Limit 1G link enforcement
Date: Tue, 09 Dec 2014 13:26:33 -0500 (EST)
Message-ID: <20141209.132633.1214519660531038500.davem@davemloft.net>
References: <1417608920-30867-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yaniv.Rosner@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaLIS0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:26:37 -0500
In-Reply-To: <1417608920-30867-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 3 Dec 2014 14:15:20 +0200

> From: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
> 
> Change 1G-SFP module detection by verifying not only that it's not
> compliant with 10G-Ethernet, but also that it's 1G-ethernet compliant.
> 
> Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
