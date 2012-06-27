From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch] bnx2x: Change bnx2x_tests_str_arr to static
 char
Date: Wed, 27 Jun 2012 01:20:57 -0700 (PDT)
Message-ID: <20120627.012057.2161994564698831699.davem@davemloft.net>
References: <1340727063-23870-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345Ab2F0IU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:20:58 -0400
In-Reply-To: <1340727063-23870-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Tue, 26 Jun 2012 19:11:03 +0300

> This patch changes the definition of bnx2x_tests_str_arr from char to static
> char. This correction will also eliminate the sparse warning created in commit
> cf2c1df62e065bfc15e38daf2d3479a56b320f29.
> 
> Signed-off-by: Merav Sicron <meravs@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
