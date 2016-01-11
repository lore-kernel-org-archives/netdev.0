From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Mon, 11 Jan 2016 16:31:25 -0500 (EST)
Message-ID: <20160111.163125.1974780181651011339.davem@davemloft.net>
References: <20160111093012.GA23525@gondor.apana.org.au>
	<20160111160039.GA6061@mrl.redhat.com>
	<5693E451.2000306@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, herbert@gondor.apana.org.au,
	lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, vyasevic@redhat.com,
	daniel@iogearbox.net
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759403AbcAKVb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 16:31:27 -0500
In-Reply-To: <5693E451.2000306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 11 Jan 2016 12:20:17 -0500

> I have a hard time excepting this argument.  Just because a given test
> scenario may be unreasonable now, doesn't make so in the future.  If
> there is a way to solve the problem, then it should be done.  Saying
> this isn't really a problem isn't going to make it go away.

+1
