From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] cxgb4: Add debugfs entry to enable backdoor
 access
Date: Tue, 21 Jul 2015 22:33:17 -0700 (PDT)
Message-ID: <20150721.223317.2079956100827659024.davem@davemloft.net>
References: <1437498580-18023-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbbGVFdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:33:18 -0400
In-Reply-To: <1437498580-18023-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 21 Jul 2015 22:39:40 +0530

> Add debugfs entry 'use_backdoor' to enable backdoor access to read sge
> context. By default, we read sge context's via firmware. In case of FW
> issues, one can enable backdoor access via debugfs to dump sge context
> for debugging purpose.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
> V2: Remove unnecessary braces as per comments by Sergei Shtylyov 
>     <sergei.shtylyov@cogentembedded.com>

Applied.
