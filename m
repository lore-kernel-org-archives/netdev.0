From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc-2.6 2011-05-12
Date: Thu, 12 May 2011 16:30:30 -0400 (EDT)
Message-ID: <20110512.163030.1127683523653779733.davem@davemloft.net>
References: <1305216428.5214.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932580Ab1ELUai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 16:30:38 -0400
In-Reply-To: <1305216428.5214.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 12 May 2011 17:07:08 +0100

> The following changes since commit ff538818f4a82c4cf02d2d6bd6ac5c7360b9d41d:
> 
>   sysctl: net: call unregister_net_sysctl_table where needed (2011-05-02 16:12:14 -0700)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-2.6.git sfc-2.6.39
> 
> Ben Hutchings (1):
>       sfc: Always map MCDI shared memory as uncacheable
> 
> Sorry for sending this so late.  I was really hoping to get to the
> bottom of this issue and find a simple fix.

Pulled, thanks Ben.
