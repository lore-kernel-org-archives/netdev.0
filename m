From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: cpsw: add support for fixed-links.
Date: Mon, 09 Nov 2015 22:49:51 -0500 (EST)
Message-ID: <20151109.224951.1754592431174323682.davem@davemloft.net>
References: <1447097054-4658-1-git-send-email-dtrautmann@ibhsoftec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, balbi@ti.com
To: dtrautmann@ibhsoftec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbbKJDtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 22:49:53 -0500
In-Reply-To: <1447097054-4658-1-git-send-email-dtrautmann@ibhsoftec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Trautmann <dtrautmann@ibhsoftec.com>
Date: Mon, 9 Nov 2015 20:24:14 +0100

> Add support for fixed-links in configurations without PHY.
> (e.g. connection to a switch, SGMII point to point, SFPs)
> 
> Check: Documentation/devicetree/bindings/net/fixed-link.txt.
> 
> Signed-off-by: Daniel Trautmann <dtrautmann@ibhsoftec.com>

This patch doesn't apply cleanly at all.
