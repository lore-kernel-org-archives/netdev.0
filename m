From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] net: axienet: Support for RGMII
Date: Tue, 05 May 2015 19:35:20 -0400 (EDT)
Message-ID: <20150505.193520.1238479814165419495.davem@davemloft.net>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, srikanth.thokala@xilinx.com,
	soren.brinkmann@xilinx.com, monstr@monstr.eu, John.Linn@xilinx.com,
	anirudh@xilinx.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: michal.simek@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078AbbEEXfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:35:23 -0400
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Series applied to net-next.

Next time, you should give an initial "[PATCH 00/nn] " posting
describing overall at a high level what the series is doing.

That way I can use that information in the commit message of
a merge commit for your series, and also have one posting I
can reply to in order to give high level feedback or to simply
say I applied everything.
