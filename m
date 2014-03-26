From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: mvneta: fix usage as a module
Date: Wed, 26 Mar 2014 16:53:37 -0400 (EDT)
Message-ID: <20140326.165337.1180144527449449235.davem@davemloft.net>
References: <1395789942-20764-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, alior@marvell.com,
	steve@einval.com, linux-arm-kernel@lists.infradead.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121AbaCZUxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 16:53:40 -0400
In-Reply-To: <1395789942-20764-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Wed, 26 Mar 2014 00:25:40 +0100

> The following set of two patches fix the usage of the mvneta driver
> when built as a module, and used in RGMII configurations. It is
> somewhat similar to a previous fix that was made by Arnaud Patard, but
> which was limited to SGMII configurations.

Series applied, thanks.
