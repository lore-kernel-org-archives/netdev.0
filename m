From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net-ipv4-tcp.c-fix-warning-from-older-compilers.patch
Date: Fri, 11 Dec 2009 06:50:11 +0000
Message-ID: <20091211065011.GA6409@ff.dom.local>
References: <20091210.134613.91416472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, william.allen.simpson@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:56797 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbZLKGuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 01:50:12 -0500
Received: by fxm21 with SMTP id 21so677135fxm.1
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 22:50:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091210.134613.91416472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Replace + net-ipv4-tcpc-fix-warning.patch added to -mm tree
>>>
>>> Remove the offending code, and replace with comments.  This is an
>>> unlikely problem, so depend on human finding any future error.
>>>
>>> Signed-off-by: William.Allen.Simpson@gmail.com
>>> ---
>>>  net/ipv4/tcp.c |    9 ++++-----
>>>  1 files changed, 4 insertions(+), 5 deletions(-)
>> This is not necessary, David already _did_ the thing, and _told_ so.
> 
> Right.

But David _did_ forget to _send_ the thing to the list. ;-)

Jarek P.
