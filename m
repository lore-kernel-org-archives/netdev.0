From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: extend round-robin mode
Date: Thu, 07 Nov 2013 15:12:55 -0500 (EST)
Message-ID: <20131107.151255.2299720834779367028.davem@davemloft.net>
References: <1383655902-18744-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692Ab3KGUM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 15:12:56 -0500
In-Reply-To: <1383655902-18744-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue,  5 Nov 2013 13:51:40 +0100

> This small patchset adds a new option called packets_per_slave to the
> bonding which aims to extend round-robin mode with the following effects:
> 0 - choose the slave id at random
> 1 - packet per slave (standard round-robin, default option value)
>  >1 - transmit >1 packets per slave, switch the slaves in round-robin
> Patch02 adds a description for the new option to the bonding documentation.

Series applied, thanks.
