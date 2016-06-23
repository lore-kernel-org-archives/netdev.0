From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ti_cpsw: Check for disabled child nodes
Date: Thu, 23 Jun 2016 15:12:34 -0400 (EDT)
Message-ID: <20160623.151234.681812893493947665.davem@davemloft.net>
References: <1466468191.26723.19.camel@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, nsekhar@ti.com, netdev@vger.kernel.org,
	linux-kernel@lists.codethink.co.uk
To: ben.hutchings@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbcFWTMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 15:12:40 -0400
In-Reply-To: <1466468191.26723.19.camel@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Tue, 21 Jun 2016 01:16:31 +0100

> Dual MAC devices don't necessarily have both MACs wired up, so ignore
> those that are disabled.
> 
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

Applied.
