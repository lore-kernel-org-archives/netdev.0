From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: allow live address change
Date: Wed, 31 Dec 2014 14:18:46 -0500 (EST)
Message-ID: <20141231.141846.262862882958032522.davem@davemloft.net>
References: <20141227100142.13b7ed79@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaLaTSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:18:48 -0500
In-Reply-To: <20141227100142.13b7ed79@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>
Date: Sat, 27 Dec 2014 10:01:42 -0800

> The GRE tap device supports Ethernet over GRE, but doesn't
> care about the source address of the tunnel, therefore it
> can be changed without bring device down.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
