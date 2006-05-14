From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Sun, 14 May 2006 13:42:31 -0700 (PDT)
Message-ID: <20060514.134231.101346572.davem@davemloft.net>
References: <Pine.LNX.4.56.0605101315380.8735@ranjit.corp.google.com>
	<20060514031034.5d0396e7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ranjitm@google.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4325
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750723AbWENUmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 May 2006 16:42:46 -0400
To: akpm@osdl.org
In-Reply-To: <20060514031034.5d0396e7.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Sun, 14 May 2006 03:10:34 -0700

> It's a bit sad to be taking a clone of a clone like this.
> Avoidable?

Besides, clones of clones are illegal, if it's already a clone
you must make a copy.
