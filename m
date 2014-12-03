From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Tue, 02 Dec 2014 21:14:49 -0800 (PST)
Message-ID: <20141202.211449.2074426768363313524.davem@davemloft.net>
References: <5A90DA2E42F8AE43BC4A093BF0678848DEE09A@SHSMSX104.ccr.corp.intel.com>
	<20141202.203511.1346917579566370675.davem@davemloft.net>
	<5A90DA2E42F8AE43BC4A093BF0678848DEE0DC@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: fan.du@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbaLCFK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 00:10:26 -0500
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF0678848DEE0DC@SHSMSX104.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Du, Fan" <fan.du@intel.com>
Date: Wed, 3 Dec 2014 04:50:21 +0000

> Do you have any better idea to achieve what you said besides this patch approach
> without both fragmentation and ICMP message at the same time to cater for all kinds
> tunnel tech?

I am not obligated to figure out for you how to design a correctly
implemented patch.

But I am obligated to keep a bad change from going into the tree and
that is what I am doing.
