From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/4] drivers: net: xgene: Add support for
 Classifier engine
Date: Wed, 17 Feb 2016 12:05:17 -0500 (EST)
Message-ID: <20160217.120517.1874370262056055172.davem@davemloft.net>
References: <1455327425-8294-1-git-send-email-isubramanian@apm.com>
	<1455327425-8294-2-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, kdinh@apm.com, tinamdar@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965115AbcBQRFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 12:05:22 -0500
In-Reply-To: <1455327425-8294-2-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Fri, 12 Feb 2016 17:37:02 -0800

> +static void xgene_cle_dn_to_hw(struct xgene_cle_ptree_ewdn *dn,
> +			       u32 *buf, u32 jb)
> +{
> +	u32 i, j = 0;
> +	u32 npp;
> +	struct xgene_cle_ptree_branch *br;

Please order local variables from longest to shortest line (reverse christmas
tree format).

Please address this for your entire submission.

Thank you.
