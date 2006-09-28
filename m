From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp-lp: prevent chance for oops
Date: Thu, 28 Sep 2006 14:40:29 -0700 (PDT)
Message-ID: <20060928.144029.32722435.davem@davemloft.net>
References: <3feffd230609280343o1975ee70o8a55acf3e5d4769e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28891
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161183AbWI1Vk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:40:26 -0400
To: hswong3i@gmail.com
In-Reply-To: <3feffd230609280343o1975ee70o8a55acf3e5d4769e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Wong Edison" <hswong3i@gmail.com>
Date: Thu, 28 Sep 2006 18:43:58 +0800

>   *
> - * Version: $Id: tcp_lp.c,v 1.24 2006/09/05 20:22:53 hswong3i Exp $
> + * Version: $Id: tcp_lp.c,v 1.25 2006/09/22 20:50:27 hswong3i Exp $

BTW, I'm deleting this line from the source file in the tree
because every patch you send doesn't apply cleanly because
your patch is against a different string on this line and we
don't use $Id$ tags in the kernel sources anyways.
