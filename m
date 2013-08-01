From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/2] ipv6: prevent race between address creation
 and removal
Date: Thu, 01 Aug 2013 14:17:45 -0700 (PDT)
Message-ID: <20130801.141745.1455068808632855023.davem@davemloft.net>
References: <1375346488-1001-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab3HAVRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 17:17:47 -0400
In-Reply-To: <1375346488-1001-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  1 Aug 2013 10:41:26 +0200

> Jiri Benc (1):
>   ipv6: prevent race between address creation and removal
> 
> Jiri Pirko (1):
>   ipv6: move peer_addr init into ipv6_add_addr()

Series applied, thanks Jiri.
