From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: core: sock.c coding style fixes
Date: Tue, 15 Sep 2015 11:53:58 -0700 (PDT)
Message-ID: <20150915.115358.27550892434513423.davem@davemloft.net>
References: <87mvwnbkzr.fsf@x220.int.ebiederm.org>
	<55F8652D.30809@vipserv.org>
	<20150915184346.GA7817@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cristos@vipserv.org, ebiederm@xmission.com, edumazet@google.com,
	netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbIOSx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 14:53:59 -0400
In-Reply-To: <20150915184346.GA7817@Alexeis-MacBook-Pro-2.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 15 Sep 2015 11:43:49 -0700

> imo it makes sense to fix coding style only if nearby lines are
> affected by meaningful changes.
> Just blank rewrites like these are more harmful than useful.
> They distort git blame, make backporting harder, etc.

+1
