From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] Add SGMII based 1GbE support to APM X-Gene SoC
 ethernet driver
Date: Tue, 14 Oct 2014 16:10:01 -0400 (EDT)
Message-ID: <20141014.161001.808204632101029906.davem@davemloft.net>
References: <1413245135-2989-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, kchudgar@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524AbaJNUKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:10:04 -0400
In-Reply-To: <1413245135-2989-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Mon, 13 Oct 2014 17:05:31 -0700

> Adding SGMII based 1GbE basic support to APM X-Gene SoC ethernet driver.
> 
> v2: Address comments from v1
> * Split the patchset into two, the first one being preparatory patch
> * Added link_state function pointer to the xgene_mac_ops structure
> * Added xgene_indirect_ctl structure for indirect read/write arguments
> 
> v1:
> * Initial version

Series applied, thanks.
