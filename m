From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] Altera TSE: Correct typecast issue
 detected by kbuild test robot
Date: Fri, 21 Mar 2014 15:37:11 -0400 (EDT)
Message-ID: <20140321.153711.1719844368106040992.davem@davemloft.net>
References: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
	<1395366197-9781-3-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaCUThN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 15:37:13 -0400
In-Reply-To: <1395366197-9781-3-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Thu, 20 Mar 2014 20:43:16 -0500

> This patch addresses a portable pointer arithmetic issue in the
> original submission found by the kbuild test robot.
> 
> config: make ARCH=i386 allyesconfig
 ...
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>

Applied.
