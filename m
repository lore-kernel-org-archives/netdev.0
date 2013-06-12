From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] tcp: introduce a per-route knob for quick ack
Date: Wed, 12 Jun 2013 03:02:24 -0700 (PDT)
Message-ID: <20130612.030224.1420421159493116339.davem@davemloft.net>
References: <1371030955-6740-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rick.jones2@hp.com,
	stephen@networkplumber.org, tgraf@suug.ch, David.Laight@ACULAB.COM
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab3FLKC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 06:02:27 -0400
In-Reply-To: <1371030955-6740-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 12 Jun 2013 17:55:54 +0800

> According to previous discussion [1], it seems there is no
> reasonable heuristics.
 ...
> 1. http://marc.info/?t=136507071100004&r=1&w=2

You can't just explain the entire essence of why your patch is
necessary by referring to a URL that might disappear some day.

I'm not even going to look there to review your patch, that
should never be necessary.  A patch and it's commit message
should be as self contained as possible.

It is required that you explain, in full detail, and covering
all of the perspectives, the whole issue of ACK behavior in
the commit message.

Otherwise you're making things more difficult for the person who has
to look at this commit in the future.

Thanks.
