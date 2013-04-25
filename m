From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/7] qlcnic: Rename the IRQ description.
Date: Thu, 25 Apr 2013 19:21:52 -0400 (EDT)
Message-ID: <20130425.192152.930991447232787505.davem@davemloft.net>
References: <1366848330.2600.10.camel@bwh-desktop.uk.solarflarecom.com>
	<BECD8E8A1B550B48A1BF97C13991F60E2FFBDB@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	sony.chacko@qlogic.com, shahed.shaikh@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com, himanshu.madhani@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759715Ab3DYXV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 19:21:57 -0400
In-Reply-To: <BECD8E8A1B550B48A1BF97C13991F60E2FFBDB@avmb2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Thu, 25 Apr 2013 23:11:05 +0000

> We will like to add the qlcnic prefix to the above format, as it makes it
> easier for an end user to identify which driver these entries belongs to,
> without having to run addition command.

This is illogical, and wrong.

By being different, you are making it MORE DIFFICULT for users because
they have to specially accomodate your unique conventions.

Please follow what other drivers do.

If you disagree with what the convention is, start a discussion about
changing it, rather than doing whatever you feel like doing in your
drivers.
