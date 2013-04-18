From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-04-17
Date: Thu, 18 Apr 2013 14:51:28 -0400 (EDT)
Message-ID: <20130418.145128.2233185650892865601.davem@davemloft.net>
References: <1366232596-23172-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab3DRSvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:51:32 -0400
In-Reply-To: <1366232596-23172-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed, 17 Apr 2013 23:03:15 +0200

> here you have a patch intended for net/linux-3.9 (if it can still make it..).
> It is fixing a MAC address check routine which does not behave
> correctly in case of multiple mesh interfaces in the same node.

Pulled.

> This patch will generate some conflicts the next time you will merge net in
> net-next and will also break it (this happens because the function this patch is
> changing is used by some patches existing in net-next only).
> 
> I will send some instruction on how to solve the merge conflicts and a patch to
> fix net-next soon.

Thanks.
