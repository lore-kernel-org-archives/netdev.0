From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Initialize flow flags in input path
Date: Tue, 29 Sep 2015 21:52:54 -0700 (PDT)
Message-ID: <20150929.215254.543961910298277124.davem@davemloft.net>
References: <1443578827-40533-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbbI3Ewz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:52:55 -0400
In-Reply-To: <1443578827-40533-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 29 Sep 2015 19:07:07 -0700

> The fib_table_lookup tracepoint found 2 places where the flowi4_flags is
> not initialized.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
