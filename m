From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 20151216
Date: Wed, 16 Dec 2015 11:10:22 -0500 (EST)
Message-ID: <20151216.111022.886656501693915984.davem@davemloft.net>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811AbbLPQKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 11:10:24 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Wed, 16 Dec 2015 15:49:21 +0800

> here you have our batch of patches intended for net-next.
> 
> Marek Lindner is introducing a list of direct neighbours per interface
> and is exporting it via debugfs. This comes very handy in case of
> network debugging or simple topology analysis.
> 
> Add lock protection for CRC computation in the Bridge Loop Avoidance
> code to prevent racy updates, by Simon Wunderlich.
> 
> Update my email address in the relevant files.
> 
> Other than those changes you also have some code restyling, cleanups
> and minor fixes..
> 
> Please pull or let me know of any problem!

Pulled, thanks Antonio.
