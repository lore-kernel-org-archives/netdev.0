From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ipv4: Use PTR_ERR_OR_ZERO
Date: Mon, 27 Jan 2014 13:11:11 -0800 (PST)
Message-ID: <20140127.131111.1425968325261239328.davem@davemloft.net>
References: <1390805037-20540-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patches@linaro.org
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbaA0VLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 16:11:12 -0500
In-Reply-To: <1390805037-20540-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Mon, 27 Jan 2014 12:13:57 +0530

> PTR_RET is deprecated. Use PTR_ERR_OR_ZERO instead. While at it
> also include missing err.h header.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
