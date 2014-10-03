From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Fri, 03 Oct 2014 12:38:06 -0700 (PDT)
Message-ID: <20141003.123806.183331913071081861.davem@davemloft.net>
References: <20141001203345.3321.99675.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	eric.dumazet@gmail.com, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028AbaJCTgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 15:36:01 -0400
In-Reply-To: <20141001203345.3321.99675.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 01 Oct 2014 22:35:31 +0200

> This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> from the qdisc layer, to implement dequeue bulking.

Series applied, thanks for all of your hard work!
