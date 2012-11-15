From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2012-11-14
Date: Wed, 14 Nov 2012 22:11:11 -0500 (EST)
Message-ID: <20121114.221111.1784435467222988184.davem@davemloft.net>
References: <1352924189-18843-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933136Ab2KODLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 22:11:13 -0500
In-Reply-To: <1352924189-18843-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed, 14 Nov 2012 21:16:18 +0100

> here is again our new patchset intended for net-next/linux-3.8.
> Patch 1/11 has been modified to address the problems you pointed out last time;
> however hash_bytes has kept its inline tag and it has been moved to hash.h (in
> this way it becomes usable by the rest of the batman-adv code for new changes).

Pulled, thanks.
