From: David Miller <davem@davemloft.net>
Subject: Re: [patch] neighbour.c, pneigh_get_next() skips published entry
Date: Mon, 25 Sep 2006 16:47:31 -0700 (PDT)
Message-ID: <20060925.164731.71091985.davem@davemloft.net>
References: <20060925164535.4245ee02.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jari.takkala@q9.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8916
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751079AbWIYXrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 19:47:46 -0400
To: akpm@osdl.org
In-Reply-To: <20060925164535.4245ee02.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Mon, 25 Sep 2006 16:45:35 -0700

> I've been sitting on this patch because afaik the problem which it purports
> to fix remains unfixed.
> 
> Should I drop it??
> 
> Thanks.

Please drop it, the patch submitted didn't give us the feedback
and test results we asked for which is necessary to pinpoint the
true issue here.
