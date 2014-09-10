From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] sunvnet: Reduce LDC message overhead.
Date: Wed, 10 Sep 2014 15:25:28 -0700 (PDT)
Message-ID: <20140910.152528.391406680350942661.davem@davemloft.net>
References: <20140904.223724.206826043871814498.davem@davemloft.net>
	<20140908143802.GF31377@oracle.com>
	<20140910140434.GA14466@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaIJWZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 18:25:28 -0400
In-Reply-To: <20140910140434.GA14466@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 10 Sep 2014 10:04:34 -0400

> Excuse me if I am missing something obvious, but what was the 
> verdict on this? Is there any additional clarification/information 
> I can provide, if this is being mulled over? 

After the memory barrier stuff has been sorted out, the patches
should be submitted again for review.

But I was under the impression that for now we weren't going to
be doing the new udelay() things, which defers patch #2 for now.
