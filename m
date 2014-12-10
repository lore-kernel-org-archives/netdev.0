From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Kill arch_fast_hash
Date: Wed, 10 Dec 2014 15:18:38 -0500 (EST)
Message-ID: <20141210.151838.1178381810877719493.davem@davemloft.net>
References: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932374AbaLJUSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 15:18:41 -0500
In-Reply-To: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 10 Dec 2014 16:33:09 +0100

> Due to the size of changes I have based this against net-next,
> also given 3.18 is already out. I've split this into 3 parts,
> the first two to remove existing users (so they can optionally
> go to stable) and the last one to kill the remaining library bits.
> 
> Let me know if there are any issues.

Series applied, and I'll queue patch #1 to -stable, thanks.
