From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix unreg list corruption in dev_deactivate()
Date: Sun, 20 Feb 2011 11:50:35 -0800 (PST)
Message-ID: <20110220.115035.39167926.davem@davemloft.net>
References: <20110220113429.GA27047@localhost.localdomain>
	<1298203890.8559.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stf_xl@wp.pl, netdev@vger.kernel.org, opurdila@ixiacom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49117
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750958Ab1BTTt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 14:49:58 -0500
In-Reply-To: <1298203890.8559.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 20 Feb 2011 13:11:30 +0100

> Hmm, you should read Eric B patch, he already addressed this problem a
> few hours ago.
> 
> A full audit _is_ needed.
> 
> https://lkml.org/lkml/2011/2/20/4

I'll apply Eric B.'s patch to net-2.6
