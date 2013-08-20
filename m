From: David Miller <davem@davemloft.net>
Subject: Re: pull request net: 2013-08-17
Date: Tue, 20 Aug 2013 16:55:12 -0700 (PDT)
Message-ID: <20130820.165512.254703237118139261.davem@davemloft.net>
References: <1376735694-676-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab3HTXzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 19:55:13 -0400
In-Reply-To: <1376735694-676-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Sat, 17 Aug 2013 12:34:53 +0200

> here you have another very small fix intended for net/linux-3.11.
> Tha patch properly closes a seq_read session by adding an invocation to
> skb_abort_seq_read().
> 
> Please pull or let me know if there is any problem.

Pulled thanks.

> Also, when do you plan to merge net into net-next? I have a couple of changes
> for net-next which is better to apply after the merge.

I did one the other day.  I'll probably do one the next time I merge
changes to Linus, say Thursday some time.
