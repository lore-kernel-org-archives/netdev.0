From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] net: gso_skb is now a list, needs a proper
 destructor
Date: Wed, 3 Sep 2014 12:33:58 +0200
Message-ID: <20140903123358.040382b8@redhat.com>
References: <1409701903.26422.26.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140902.150604.267268114901700475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755408AbaICKeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 06:34:04 -0400
In-Reply-To: <20140902.150604.267268114901700475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Sep 2014 15:06:04 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> Applied, thanks Eric.

I didn't see this patch the git tree, when I posted a similar fix.
So, just ignore my similar patch.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
