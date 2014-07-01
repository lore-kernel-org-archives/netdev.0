From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Tue, 01 Jul 2014 12:07:30 -0700 (PDT)
Message-ID: <20140701.120730.2210532934459689553.davem@davemloft.net>
References: <alpine.DEB.2.10.1407010937120.5997@tabini.allcutt.me.uk>
	<20140701.110510.2218293817137911715.davem@davemloft.net>
	<alpine.DEB.2.10.1407011912440.5997@tabini.allcutt.me.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: edward.allcutt@openmarket.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbaGATHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 15:07:33 -0400
In-Reply-To: <alpine.DEB.2.10.1407011912440.5997@tabini.allcutt.me.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Allcutt <edward.allcutt@openmarket.com>
Date: Tue, 1 Jul 2014 19:50:15 +0100 (BST)

> Is there another reason you dislike this approach?

I didn't say I won't apply the patch, actually the email you are
replying to is strictly about figuring out what's happening on
the OpenBSD systems for their sake.
