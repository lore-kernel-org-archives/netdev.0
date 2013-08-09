From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: via-rhine: Fix incorrect placement of
 __initdata
Date: Fri, 09 Aug 2013 13:24:45 -0700 (PDT)
Message-ID: <20130809.132445.1685876801558057194.davem@davemloft.net>
References: <1375871896-25821-1-git-send-email-sachin.kamat@linaro.org>
	<1375871896-25821-2-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rl@hellgate.ch
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031006Ab3HIUYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 16:24:46 -0400
In-Reply-To: <1375871896-25821-2-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Wed,  7 Aug 2013 16:08:16 +0530

> __initdata should be placed between the variable name and equal
> sign for the variable to be placed in the intended section.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
