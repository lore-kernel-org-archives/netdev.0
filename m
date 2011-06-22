From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 13:27:51 -0700 (PDT)
Message-ID: <20110622.132751.674782161298588383.davem@davemloft.net>
References: <20110622105434.GE16021@Chamillionaire.breakpoint.cc>
	<4E01E1FD.8010802@oracle.com>
	<4E0228C3.8090402@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.haxby@oracle.com, fw@strlen.de, fbl@redhat.com,
	netdev@vger.kernel.org, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758042Ab1FVU2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 16:28:03 -0400
In-Reply-To: <4E0228C3.8090402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 22 Jun 2011 13:39:15 -0400

> davem -- as I don't monitor this list, are you indicating that you are
> more amenable to this code being accepted upstream?  Or is that part of
> the debate still ongoing?

I'd rather have something like xt_SYSRQ in the tree than the original
proposal in this thread.

Work it out with the netfilter developers if you want to see it
integrated.
