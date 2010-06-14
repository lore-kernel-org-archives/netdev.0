From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fragment: add fast path
Date: Sun, 13 Jun 2010 18:18:57 -0700 (PDT)
Message-ID: <20100613.181857.189703148.davem@davemloft.net>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58312
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754960Ab0FNBSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 21:18:46 -0400
In-Reply-To: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 14 Jun 2010 07:16:35 +0800

> As the fragments are usually in order,

In what universe does this happen "usually"?

Linux has been outputting fragments in reverse order for more than 10
years.

I'm not applying this patch.
