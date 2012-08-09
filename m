From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/14] some netpoll and netconsole fixes
Date: Thu, 09 Aug 2012 16:30:46 -0700 (PDT)
Message-ID: <20120809.163046.584126910434037730.davem@davemloft.net>
References: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab2HIXar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 19:30:47 -0400
In-Reply-To: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu,  9 Aug 2012 23:00:12 +0800

> V3:
> * add more patches
> * update patch 7 as David suggested
> 
> V2:
> * update patch 1/8 as Eric suggested
> * drop the bridge patch, add comments instead
> * add patch 8/8
> 
> This patchset fixes serval problems in netconsole and netpoll.
> 
> I ran this patch in my KVM guest with some netpoll test cases,
> even covered with some corner cases, everything worked as expected.

All applied to 'net', thanks for fixing all of this stuff.
