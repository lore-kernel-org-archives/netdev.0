From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch 0/11 v2] bnx2x: ethtool and other enhancements
Date: Tue, 19 Jun 2012 14:35:01 -0700 (PDT)
Message-ID: <20120619.143501.1857341441768999570.davem@davemloft.net>
References: <1340104634-14353-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776Ab2FSVfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:35:02 -0400
In-Reply-To: <1340104634-14353-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Tue, 19 Jun 2012 14:17:03 +0300

> This patch series adds few features to bnx2x:
> Add support for external LB in ethtool self-test
> Enable UDP RSS on 4-tupple, controlled by ethtool
> Support up to 63 RSS queues (rather than 16)
> Add support for setting the desired number of RSS queues via ethtool
> Allow to configure dcbx admin params from all drivers on a single physical port
> Add FCoE capabilities advertisement

All applied, thanks.
