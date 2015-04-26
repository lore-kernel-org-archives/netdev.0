From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] altera tse: add support for fixed-links.
Date: Sun, 26 Apr 2015 16:07:41 -0400 (EDT)
Message-ID: <20150426.160741.554416361572963947.davem@davemloft.net>
References: <1429633945-30463-1-git-send-email-ennoerlangen@gmail.com>
	<1429978072-8376-1-git-send-email-ennoerlangen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org, ennoerlangen@gmail.com
To: ennoerlangen@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbbDZUHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 16:07:43 -0400
In-Reply-To: <1429978072-8376-1-git-send-email-ennoerlangen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <ennoerlangen@googlemail.com>
Date: Sat, 25 Apr 2015 18:07:52 +0200

> From: Andreas Oetken <ennoerlangen@gmail.com>
> 
> Add support for fixed-links in configurations without PHY.
> (e.g. connection to a switch, SGMII point to point, SFPs)
> 
> Check: Documentation/devicetree/bindings/net/fixed-link.txt.
> Signed-off-by: Andreas Oetken <ennoerlangen@gmail.com>

Applied.
