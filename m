From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 RESEND 3/3] neigh: disallow un-init_net to change
 thresh of neigh
Date: Wed, 19 Jun 2013 21:14:01 -0700 (PDT)
Message-ID: <20130619.211401.813798535582947227.davem@davemloft.net>
References: <1371693694-18531-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1371693694-18531-3-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754Ab3FTEOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 00:14:02 -0400
In-Reply-To: <1371693694-18531-3-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 20 Jun 2013 10:01:34 +0800

> thresh and interval are global resources,
> only init net can change them.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied.
