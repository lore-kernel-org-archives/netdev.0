From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/2] team: fix port list dump for big number of
 ports
Date: Fri, 31 May 2013 17:32:08 -0700 (PDT)
Message-ID: <20130531.173208.1512120120728124902.davem@davemloft.net>
References: <1369839777-19158-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, sasha.levin@oracle.com,
	akpm@linux-foundation.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755267Ab3FAAcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:32:09 -0400
In-Reply-To: <1369839777-19158-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 29 May 2013 17:02:55 +0200

> Jiri Pirko (2):
>   list: introduce list_first_entry_or_null
>   team: fix port list dump for big number of ports

Both applied, thanks Jiri.
