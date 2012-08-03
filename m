From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Fri, 03 Aug 2012 07:51:56 +0200
Message-ID: <1343973116.9299.604.camel@edumazet-glaptop>
References: <50179F66.1000604@parallels.com> <878ve0dtw3.fsf@xmission.com>
	 <1343903310.9299.184.camel@edumazet-glaptop>
	 <20120802.162601.2080519313891137444.davem@davemloft.net>
	 <1343972729.9299.596.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, xemul@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64169 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab2HCFwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 01:52:03 -0400
Received: by wgbdr13 with SMTP id dr13so305599wgb.1
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 22:52:01 -0700 (PDT)
In-Reply-To: <1343972729.9299.596.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-03 at 07:45 +0200, Eric Dumazet wrote:

> Yes I am sure (by the way my output device was dummy0, not lo, but its
> the same for the case here)

Of course, the ifindex was related to lo, sorry for the confusion,
-ENOCOFFEE_YET_THIS_MORNING
