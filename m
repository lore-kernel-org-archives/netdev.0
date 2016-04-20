From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Wed, 20 Apr 2016 12:07:02 -0400 (EDT)
Message-ID: <20160420.120702.2287761401369585570.davem@davemloft.net>
References: <1461167023-7640-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbcDTQHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 12:07:04 -0400
In-Reply-To: <1461167023-7640-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Wed, 20 Apr 2016 08:43:43 -0700

> This patch has been tested with mofified iproute2 ifstat.

Can you please send me the patch you are using?  I want to do some quick testing
on sparc64 before I push this out.

Thanks.
