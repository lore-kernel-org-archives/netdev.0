From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/24] net, diet: Default to small TCP hash tables on
 small kernels
Date: Mon, 05 May 2014 23:12:06 -0400 (EDT)
Message-ID: <20140505.231206.148345507012697578.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-6-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933811AbaEFDMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:12:08 -0400
In-Reply-To: <1399328773-6531-6-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:25:54 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Same comment as per other hash table reductions, this doesn't
make any sense even for the claimed goal.
