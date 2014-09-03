From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] net: Validate frames going through the direct_xmit path
Date: Wed, 3 Sep 2014 13:57:50 +0200
Message-ID: <20140903135750.7cf9a94e@redhat.com>
References: <20140902225548.885.79277.stgit@ahduyck-bv4.jf.intel.com>
	<1409700648.26422.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<5406810A.9070900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15744 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756228AbaICL54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 07:57:56 -0400
In-Reply-To: <5406810A.9070900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Sep 2014 19:46:34 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> Alternative patches always welcome. :-)  My goal at this point is to
> just have my vhost_net interface work so I can get back to my other
> development work.  I will submit a v2 in the morning if I don't see
> anything.

I've posted a followup, and gave you the SoB.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
