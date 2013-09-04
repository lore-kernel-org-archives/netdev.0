From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] tunnels: harmonize skb scrubbing during
 encapsulation/decapsulation
Date: Wed, 04 Sep 2013 00:52:43 -0400 (EDT)
Message-ID: <20130904.005243.1025774563415043155.davem@davemloft.net>
References: <CALnjE+pKi=p0y2ot2qWG1w=pxEUcPUKY+_UUi0RXbnGqVk9poA@mail.gmail.com>
	<1378128898-15136-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com,
	dev@openvswitch.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760947Ab3IDEwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 00:52:45 -0400
In-Reply-To: <1378128898-15136-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon,  2 Sep 2013 15:34:53 +0200

> We talk recently about harmonizing tunnels so they behave consistently wrt. SKB
> orphaning, cleaning netfilter state, etc.
> The goal of this serie is to achieve this.
> 
> Note that I test only ipip, sit and ip6_tunnels modules.
> 
> v2: add patch 2/5
>     rebase on head
>     remove 'RFC' prefix

Series applied.
