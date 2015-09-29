From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: Fix CWV being too strict on thin
 streams
Date: Mon, 28 Sep 2015 22:37:13 -0700 (PDT)
Message-ID: <20150928.223713.702745633526922432.davem@davemloft.net>
References: <1443026993-12358-1-git-send-email-bro.devel+kernel@gmail.com>
	<1443371580.3273.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bro.devel@gmail.com, ncardwell@google.com, netdev@vger.kernel.org,
	bro.devel+kernel@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbbI2FhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:37:14 -0400
In-Reply-To: <1443371580.3273.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 27 Sep 2015 09:33:00 -0700

> David, any idea of what happened to Bendik patch ?
> 
> https://patchwork.ozlabs.org/patch/521765
> 
> Do we need to re-submit or something ?

Sorry, applied and build testing, I don't know how this disappeared
like that :-)
