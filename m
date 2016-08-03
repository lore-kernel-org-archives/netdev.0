From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/18] liquidio support for new device cn23xx
Date: Wed, 03 Aug 2016 15:05:04 -0700 (PDT)
Message-ID: <20160803.150504.2220219685584839824.davem@davemloft.net>
References: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758358AbcHCWFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 18:05:08 -0400
In-Reply-To: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Wed, 3 Aug 2016 11:55:31 -0700

> Please consider following patches for support of new device
> CN23XX in liquidio family of adapters. Patches may have to
> be applied in following order as some of the patches depend
> on earlier patches.

You can't have the same Subject line text for every patch in the
series.

It is required that you use unique subject lines so that someone
scanning the shortlog can see what is unique in each of these patches.

And don't try to thward this by saying something like:

	liquidio support for new device cn23xx part 1

Really describe in words what each change is uniquely doing.
