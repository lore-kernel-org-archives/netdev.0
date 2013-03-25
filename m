From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1]core:Change a wrong explain about dev_get_by_name
Date: Mon, 25 Mar 2013 12:09:40 -0400 (EDT)
Message-ID: <20130325.120940.864632931813432788.davem@davemloft.net>
References: <CA+qZnSTm8kdmrzQLc03Jyk81cBtEpCNHqsT1fFCQ_vstzYcOiw@mail.gmail.com>
	<515070CA.2010701@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tingw.liu@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	linus971@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758458Ab3CYQJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:09:42 -0400
In-Reply-To: <515070CA.2010701@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 25 Mar 2013 19:44:10 +0400

>    It seems your patch has all the tabs replaced by spaces.

I think this patch should simply be aborted.  It hasn't addressed any
of Eric Dumazet's concerns, the patch submitter can't even keep the
patch from being corrupted by his email client, and the patch is of
near zero value as far as I'm concerned especially considering how
much work and effort is going into hand holding this patch submitter.
