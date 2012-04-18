From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2012-04-18
Date: Wed, 18 Apr 2012 13:22:48 -0400 (EDT)
Message-ID: <20120418.132248.2265308681920218130.davem@davemloft.net>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab2DRR0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 13:26:04 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed, 18 Apr 2012 11:59:57 +0200

> this is the fixed version of my previous pull request (issued on 2012-04-17).
> In this patchset the issues you reported have been fixed; moreover I'm
> also including two new patches (1/13 and 2/13) which are respectively:
> 
> 1/13) a fix for Al Viro's report about the missing htons()
> 2/13) a fix for a wrongly duplicated line in a comment
> 
> The following changes since commit ecffe75f934b4e3c5301fe5db278068e0efb0d6b:
> 
>   hippi: fix printk format in rrunner.c (2012-04-16 23:48:38 -0400)
> 
> are available in the git repository at:
> 
>   git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

This looks a lot better, pulled, thanks!
