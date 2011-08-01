From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/7] dccp: add support for dynamic
 parameter updates
Date: Mon, 01 Aug 2011 00:10:42 -0700 (PDT)
Message-ID: <20110801.001042.6263177526030880.davem@davemloft.net>
References: <test_tree_patch_set_update_2011-07-25>
	<1311600996-6712-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab1HAHLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 03:11:51 -0400
In-Reply-To: <1311600996-6712-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jul 2011 07:36:29 -0600

> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

I did a test pull and this URL doesn't work:

[davem@dokdo net-next]$ git pull git://eden-feed.erg.abdn.ac.uk/net-next-2.6 dccp
fatal: The remote end hung up unexpectedly
[davem@dokdo net-next]$ git pull git://eden-feed.erg.abdn.ac.uk/net-next-2.6
fatal: The remote end hung up unexpectedly
[davem@dokdo net-next]$ 
