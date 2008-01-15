From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] [IPV4] fib hash|trie initialization
Date: Mon, 14 Jan 2008 23:14:30 -0800 (PST)
Message-ID: <20080114.231430.220952834.davem@davemloft.net>
References: <20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114210008.784db159@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40917
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752271AbYAOHOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 02:14:37 -0500
In-Reply-To: <20080114210008.784db159@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Mon, 14 Jan 2008 21:00:08 -0800

> Initialization of the slab cache's should be done when IP is
> initialized to make sure of available memory, and that code
> can be marked __init.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

Applied.
