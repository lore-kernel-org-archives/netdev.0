From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2 1/1] fix error handle in ip_mc_add_src()
Date: Tue, 22 Nov 2011 16:22:37 -0500 (EST)
Message-ID: <20111122.162237.1924632736368263053.davem@davemloft.net>
References: <1321891516.14281.62.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dlstevens@us.ibm.com
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758599Ab1KVVWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 16:22:52 -0500
In-Reply-To: <1321891516.14281.62.camel@barry.pixelworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Tue, 22 Nov 2011 00:05:16 +0800

> from: Jun Zhao <mypopydev@gmail.com>
> 
> When add sources to interface failure, need to roll back the sfcount[MODE] 
> to before state. We need to match it corresponding. 
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>

Please use an appropriate prefix in your subject line after the
closing "]" bracket.  For example, something like "ipv4: " for this
specific patch is fine.

Your patch has also been corrupted by your email client, it turned tab
characters into spaces amongst other things.  Please correct this,
email a test patch to yourself, and make absolutely sure you are able
to successfully apply it before you retry submitting your fix here.

Thank you.
