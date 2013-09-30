From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/3] net: ethernet: cpsw: Remove redundant of_match_ptr
Date: Mon, 30 Sep 2013 10:47:05 -0500
Message-ID: <52499CF9.8090206@ti.com>
References: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: Sachin Kamat <sachin.kamat@linaro.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:45366 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755243Ab3I3PrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 11:47:07 -0400
In-Reply-To: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org>
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
