From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] net: introduce IFF_NO_QUEUE as successor of zero
 tx_queue_len
Date: Mon, 17 Aug 2015 08:51:21 +0200
Message-ID: <20150817085121.419a1d28@redhat.com>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
	<20150813104950.1b8346f2@urahara>
	<20150813204037.3c4e68a4@redhat.com>
	<20150813121157.5166efb1@urahara>
	<20150814084153.GI32353@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, fw@strlen.de, cwang@twopensource.com,
	eric.dumazet@gmail.com
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774AbbHQGvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 02:51:25 -0400
In-Reply-To: <20150814084153.GI32353@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 14 Aug 2015 10:41:53 +0200 Phil Sutter <phil@nwl.cc> wrote:

> On Thu, Aug 13, 2015 at 12:11:57PM -0700, Stephen Hemminger wrote:
[...]
> > 
> > But adding a flag risks breaking external scripts.
> 
> Could you please elaborate on this? As far as I can tell, introducing a
> separate flag is the only solution *not* breaking existing scripts. So
> if you see the rub, I would like to know where exactly it is.

I agree with Phil.  AFAIC see this approach does not break existing
scripts.

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
