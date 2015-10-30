From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] net: clean up interactions of
 CHECKSUM_PARTIAL and fragmentation
Date: Fri, 30 Oct 2015 19:37:48 +0900 (KST)
Message-ID: <20151030.193748.1337418825359803374.davem@davemloft.net>
References: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
	<87wpu7bamv.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, vyasevich@gmail.com,
	bcodding@redhat.com, tom@herbertland.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759587AbbJ3Khu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 06:37:50 -0400
In-Reply-To: <87wpu7bamv.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 28 Oct 2015 10:33:28 +0100

> Those patches are actually for net and not for net-next,
> sorry. Guess I messed it up with Ctrl-R foo.

Ok, in that case since:

1) I already have a pull request pending (which is only delayed because
   of you, hehe :-)

2) 4.3 is likely to be finalized on Sunday.

3) I am getting on a plane first thing tomorrow morning.

I think this will end up going via the upcoming merge window and queud
up for -stable.

Just FYI...
