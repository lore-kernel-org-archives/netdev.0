From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/3] net: ethernet: cpsw-phy-sel: Remove redundant of_match_ptr
Date: Mon, 30 Sep 2013 10:47:21 -0500
Message-ID: <52499D09.9070903@ti.com>
References: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org> <1380515114-2823-2-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: Sachin Kamat <sachin.kamat@linaro.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:43458 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755367Ab3I3PrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Sep 2013 11:47:24 -0400
In-Reply-To: <1380515114-2823-2-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 29 September 2013 11:25 PM, Sachin Kamat wrote:
> The data structure of_match_ptr() protects is always compiled in.
> Hence of_match_ptr() is not needed.
>
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
