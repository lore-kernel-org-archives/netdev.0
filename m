From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2012-02-17
Date: Fri, 17 Feb 2012 15:23:23 -0500 (EST)
Message-ID: <20120217.152323.2251437927591117547.davem@davemloft.net>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: lindner_marek@yahoo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54321 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753659Ab2BQUYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 15:24:30 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>
Date: Fri, 17 Feb 2012 15:18:20 +0800

> The following changes since commit dcd6c92267155e70a94b3927bce681ce74b80d1f:
> 
>   Linux 3.3-rc1 (2012-01-19 15:04:48 -0800)
> 
> are available in the git repository at:
> 
>   git://git.open-mesh.org/linux-merge.git batman-adv-for-davem

Somethings up:

[davem@drr net-next]$ git pull git://git.open-mesh.org/linux-merge.git batman-adv-for-davem
fatal: Couldn't find remote ref batman-adv-for-davem

which is strange because I can see the tag there on git.open-mesh.org when
I check it with my web browser.
