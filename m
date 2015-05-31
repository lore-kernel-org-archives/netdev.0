From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2015-05-29
Date: Sun, 31 May 2015 01:08:05 -0700 (PDT)
Message-ID: <20150531.010805.867337412648153602.davem@davemloft.net>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364AbbEaIIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 04:08:10 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Fri, 29 May 2015 11:05:12 +0200

> after quite some time of silence (mostly due to me being rather busy and not
> because we did not have any active development) here you have my first batch
> intended for net-next/linux-4.1.
> 
> In this patchset you have quite some code cleanup and style fixes. A big chunk
> of the cleanup work has been performed by Markus Pargmann, followed by a couple
> of checkpatch fixes brought by Marek Lindner.
> 
> Then we have a patch by Sven Eckelmann that disables some of the features we had
> enabled by default, because not all the users having them enabled at compile
> time are aware of those.
> For example distributions like debian enables any compile-time option
> without asking the user, thus having him using all these features without his
> explicit consent with potentially unexpected behaviours. Therefore the decision
> to disable by default not-so-user-safe options.

Pulled, thanks Antonio.
