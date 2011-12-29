From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: restore multicast rx filter on resume
Date: Thu, 29 Dec 2011 02:56:11 -0500 (EST)
Message-ID: <20111229.025611.2043166821951238153.davem@davemloft.net>
References: <20111228092714.0a6d5f80@nehalam.linuxnetplumber.net>
	<20111228.130908.182833189468208987.davem@davemloft.net>
	<20111229064849.GB8041@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab1L2H5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 02:57:22 -0500
In-Reply-To: <20111229064849.GB8041@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Zumbiehl <florz@florz.de>
Date: Thu, 29 Dec 2011 07:48:50 +0100

> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c

This file no longer exists in the current source tree.

All of the ethernet drivers have been moved to various directories
under drivers/net/ethernet

Please do not generate patches against older source trees.

And when I ask you to post a patch anew, please make it clean.  In
this case you replied to my email, added some unrelated commentary,
and then included the commit log message and the patch.

This is not the correct way to do things.  Post a fresh email, not a
reply, with a clean Subject line and the email body contents only
contain the commit log message and the subsequent patch.

If you don't do things the correct way, then the person applying your
patch has to do a lot of work editing things.  If you do it the right
way, adding your patch is very easy.

See:

	http://linux.yyz.us/patch-format.html

for more details
