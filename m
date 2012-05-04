From: David Miller <davem@davemloft.net>
Subject: Re: [Lksctp-developers] Bug: sctp packets are dropped after IPSEC
 rekeying (route cache issue)
Date: Fri, 04 May 2012 10:48:12 -0400 (EDT)
Message-ID: <20120504.104812.502049217620285020.davem@davemloft.net>
References: <4C46AA7B.3090601@6wind.com>
	<4C46FD58.9030107@hp.com>
	<4FA3AA6A.4070503@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, babu.srinivasan@gmail.com,
	lksctp-developers@lists.sourceforge.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	michael.kreuzer@nsn.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54010 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866Ab2EDOsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 10:48:43 -0400
In-Reply-To: <4FA3AA6A.4070503@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 04 May 2012 12:07:38 +0200

> Finally, this patch was never integrated into the mainline. Should I
> rebase it on the head?
> 
> I've attach the last approved patch.
> 
> Here is the original thread:
> http://sourceforge.net/mailarchive/message.php?msg_id=25786006

Vlad no longer works for HP so your email likely will bounce, and
he will not see it.

His new email address is vyasevich@gmail.com, as per the MAINTAINERS
file.
