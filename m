From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers: net: xgene: fix RGMII 10/100Mb mode
Date: Fri, 06 Nov 2015 23:31:44 -0500 (EST)
Message-ID: <20151106.233144.1936295198775628276.davem@davemloft.net>
References: <1446788107-31856-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, fchen@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbbKGEbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 23:31:48 -0500
In-Reply-To: <1446788107-31856-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Thu,  5 Nov 2015 21:35:06 -0800

> This patch fixes the RGMII 10/100M mode by reprogramming the clock.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Tested-by: Fushen Chen <fchen@apm.com>

Why are you targetting a bug fix at net-next?  That is inappropriate.
