From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan: Propagate MAC address changes properly
Date: Tue, 03 May 2016 12:34:32 -0400 (EDT)
Message-ID: <20160503.123432.2155885726607062971.davem@davemloft.net>
References: <572489C5.3020502@brocade.com>
	<20160503.001651.132843090236435270.davem@davemloft.net>
	<5728C152.7090007@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933338AbcECQev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 12:34:51 -0400
In-Reply-To: <5728C152.7090007@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Tue, 3 May 2016 16:18:42 +0100

> Given that this information is implicit in real_dev_addr

That's not the reason to make or not make the simplification I
asked you do.

You can add a multi-page comment to this code, and the confusing
tests are still rediculous.

Please add the boolean state as I asked you to.
