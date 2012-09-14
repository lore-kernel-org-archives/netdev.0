From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] ipconfig: Inform user if carrier is not ready
Date: Fri, 14 Sep 2012 15:17:24 -0400 (EDT)
Message-ID: <20120914.151724.505809965127351650.davem@davemloft.net>
References: <50525758.1090609@gmail.com>
	<50525C5D.8040302@hp.com>
	<505380A0.7020407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hp.com
To: erwanaliasr1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab2INTR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 15:17:28 -0400
In-Reply-To: <505380A0.7020407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erwan Velu <erwanaliasr1@gmail.com>
Date: Fri, 14 Sep 2012 21:08:16 +0200

> +        /* This loop is blocking the boot process until
> +         * we get the carrier or reach the timeout.
> +         * We have to inform the user about the situation as
> +         * it could look like a kernel freeze.
> +         * After CONF_WARN_CARRIER_TIMEOUT milliseconds,
> + * we display the remaing time before reaching the timeout. */

This is badly formatted, either because you explicitly did so
or because your email client corrupted the patch.

Either way you have to fix this before we can seriously consider
your patch.
