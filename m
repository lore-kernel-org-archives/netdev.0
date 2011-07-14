From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] ps3_gelic: Fix error paths when a tx dma fails
Date: Thu, 14 Jul 2011 10:12:31 -0700 (PDT)
Message-ID: <20110714.101231.2284840967835997093.davem@davemloft.net>
References: <CAHsu+b89+SN8RE4Ce-evC97pw8bgZgjnOW_+z6NDXu6bGuRO+w@mail.gmail.com>
	<20110714.083548.1565604077412861146.davem@davemloft.net>
	<4E1F22EF.4010202@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.heider@gmail.com, netdev@vger.kernel.org,
	cbe-oss-dev@lists.ozlabs.org
To: geoff@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145Ab1GNRPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 13:15:46 -0400
In-Reply-To: <4E1F22EF.4010202@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geoff Levand <geoff@infradead.org>
Date: Thu, 14 Jul 2011 10:10:07 -0700

> On 07/14/2011 08:35 AM, David Miller wrote:
>> Should I toss these into net-next-2.6 now?
> 
> It seems reasonable to add these in.  I also have a fix for an
> RX interrupt hang that I'll send you.
> 
> Acked-by: Geoff Levand <geoff@infradead.org>

Great, done.
