From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] batman-adv: fix skb->data assignment
Date: Tue, 19 Jun 2012 14:28:03 -0700 (PDT)
Message-ID: <20120619.142803.977377594415293854.davem@davemloft.net>
References: <1340133999-26838-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	stable@vger.kernel.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105Ab2FSV2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:28:04 -0400
In-Reply-To: <1340133999-26838-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Tue, 19 Jun 2012 21:26:39 +0200

> This patch has already been merged in net-next. I am sorry about that, but we
> were missing some knowledge about sending patches for stable.

You really like making my life miserable.

What is so damn complicated about:

1) BUG FIXES go to 'net'

2) NON BUG FIXES go to 'net-next'

This gets stated repeatedly here.

I do see you guys erroneously submit bug fixes into net-next all
the time but I just assumed you simply didn't give a shit about
bug fixes propagating quickly.

You guys definitely need to get your asses in gear.
