From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: ethernet: cpsw-phy-sel: Remove redundant
 of_match_ptr
Date: Tue, 01 Oct 2013 12:34:41 -0400 (EDT)
Message-ID: <20131001.123441.1182607348796452774.davem@davemloft.net>
References: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org>
	<1380515114-2823-2-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687Ab3JAQen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:34:43 -0400
In-Reply-To: <1380515114-2823-2-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Mon, 30 Sep 2013 09:55:13 +0530

> The data structure of_match_ptr() protects is always compiled in.
> Hence of_match_ptr() is not needed.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Applied.
