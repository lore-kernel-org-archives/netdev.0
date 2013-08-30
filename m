From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/7] IPv6 MLD updates
Date: Fri, 30 Aug 2013 14:38:46 -0400 (EDT)
Message-ID: <20130830.143846.2250283565647562811.davem@davemloft.net>
References: <1377881908-8022-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab3H3Sit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:38:49 -0400
In-Reply-To: <1377881908-8022-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 30 Aug 2013 18:58:21 +0200

> If there are no further objections, I'll send out the non-RFC version on
> Monday after some more testing. That's just a heads up. This set includes
> my improved fix from yesterday as well besides other things.
> 
> Thanks!

>From a coding style and general correctness perspective these changes
look fine to me.

I'll let IPV6 MLD experts comment on the semantic part.
