From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] rhashtable self-test improvements
Date: Sun, 03 May 2015 23:09:17 -0400 (EDT)
Message-ID: <20150503.230917.1809847510657005941.davem@davemloft.net>
References: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbbEDDJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 23:09:19 -0400
In-Reply-To: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 30 Apr 2015 22:37:39 +0000

> This series improves the rhashtable self-test to:
>   * Avoid allocation of test objects
>   * Measure the time of test runs
>   * Use the iterator to walk the table for consistency
>   * Account for failed insertions due to memory pressure or
>     utilization pressure
>   * Ignore failed insertions when checking for consistency

This looks find, series applied, thanks Thomas.
