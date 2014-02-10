From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6lowpan: Remove unused pointer in
 lowpan_header_create()
Date: Sun, 09 Feb 2014 18:38:29 -0800 (PST)
Message-ID: <20140209.183829.1382019488417715676.davem@davemloft.net>
References: <20140207225838.18ad2ffb@spike>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, jukka.rissanen@linux.intel.com
To: cengelma@gmx.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbaBJCic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 21:38:32 -0500
In-Reply-To: <20140207225838.18ad2ffb@spike>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Engelmayer <cengelma@gmx.at>
Date: Fri, 7 Feb 2014 22:58:38 +0100

> Commit 8df8c56a (6lowpan: Moving generic compression code into 6lowpan_iphc.c)
> left pointer 'hdr' unused - remove it.
> 
> Detected by Coverity: CID 1164868.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Applied, thanks.
