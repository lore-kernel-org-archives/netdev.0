From: David Miller <davem@davemloft.net>
Subject: Re: [next-next-2.6 PATCH] enic: Add support to configure hardware
 interrupt coalesce timers in a platform independent way
Date: Thu, 16 Jun 2011 23:57:15 -0400 (EDT)
Message-ID: <20110616.235715.2076846351080666905.davem@davemloft.net>
References: <20110615211758.28596.12341.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755545Ab1FQD5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:57:17 -0400
In-Reply-To: <20110615211758.28596.12341.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Wed, 15 Jun 2011 14:17:58 -0700

> +	/* Get interrupt coalesce timer info
> +	 */
> +
> +	err = enic_dev_intr_coal_timer_info(enic);

Please, comment should be just one line long and empty
line is superflous.
