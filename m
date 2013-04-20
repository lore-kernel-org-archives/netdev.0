From: David Miller <davem@davemloft.net>
Subject: Re: net: fix incorrect credentials passing
Date: Sat, 20 Apr 2013 16:58:15 -0400 (EDT)
Message-ID: <20130420.165815.1541030044930091056.davem@davemloft.net>
References: <alpine.LFD.2.03.1304191826080.2455@gmail.com>
	<20130419.215856.1499421731544629706.davem@davemloft.net>
	<87ip3h4gn5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	serge@hallyn.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755340Ab3DTU6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 16:58:19 -0400
In-Reply-To: <87ip3h4gn5.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 20 Apr 2013 03:53:50 -0700

> I have followed this only briefly and looked at this only quickly but I
> David I read the git history the same way you do.  I introduced a
> behavior change when the cred_to_ucred helper was introduced into
> scm_set_cred().  Linus's patch restores the original behavior.
> 
> So.
> 
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Thanks for reviewing Eric.

Applied and queued up for -stable, thanks everyone.
