From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/51] netfilter updates for net-next
Date: Sun, 07 Apr 2013 12:27:28 -0400 (EDT)
Message-ID: <20130407.122728.797835275855932038.davem@davemloft.net>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934016Ab3DGQ1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 12:27:32 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat,  6 Apr 2013 14:16:59 +0200

> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Not a very good pull request, I don't know how you were able to
successfully create it with all the inaccuracies.

The dst.c change wasn't mentioned.

and the last three patches (the error propagation fixes from Patrick)
weren't even in this tree.

I pulled, but I cannot believe that GIT didn't complain about this
or provide some kind of feedback indicating that what you're asking
me to pull doesn't match up with what's actually in that tree.

I mean, if anyone had sent you a pull request like this, you would
have rejected it.
