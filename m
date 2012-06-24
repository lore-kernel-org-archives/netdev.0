From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 net] Bug fixes for batman-adv 2012-06-23
Date: Sat, 23 Jun 2012 23:24:38 -0700 (PDT)
Message-ID: <20120623.232438.525314692277944525.davem@davemloft.net>
References: <1340465459-2949-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab2FXGYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 02:24:38 -0400
In-Reply-To: <1340465459-2949-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Sat, 23 Jun 2012 17:30:57 +0200

> Patch 1 is a fix for the AP-Isolation feature. A wrong check made all the
> broadcast packets coming from any client be dropped before delivery to the
> interface.
> Patch 2 instead fixes a "real" race condition in the TranslationTable code.
 ...
>   git://git.open-mesh.org/linux-merge.git batman-adv/maint

Pulled, thanks.
