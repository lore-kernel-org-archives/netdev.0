From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp: ptp_pch depends on x86_32
Date: Tue, 17 Jun 2014 15:44:03 -0700 (PDT)
Message-ID: <20140617.154403.435352200906683933.davem@davemloft.net>
References: <20140617115920.677401c3@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965557AbaFQWoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 18:44:04 -0400
In-Reply-To: <20140617115920.677401c3@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Tue, 17 Jun 2014 11:59:20 +0200

> The ptp_pch driver is for a companion chip to the Intel Atom E600
> series processors. These are 32-bit x86 processors so the driver is
> only needed on X86_32.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied, thanks.
