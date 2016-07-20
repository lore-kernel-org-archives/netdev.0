From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 00/10] NCSI Support
Date: Tue, 19 Jul 2016 20:49:35 -0700 (PDT)
Message-ID: <20160719.204935.206931978456558712.davem@davemloft.net>
References: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org, joel@jms.id.au,
	gerlitz.or@gmail.com, weixue@trustnetic.com, yuvali@mellanox.com,
	alexei.starovoitov@gmail.com, f.fainelli@gmail.com
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbcGTDtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 23:49:39 -0400
In-Reply-To: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Tue, 19 Jul 2016 11:54:15 +1000

> This series rebases on David's linux-net git repo ("master" branch). It's
> to support NCSI stack on drivers/net/ethernet/faraday/ftgmac100.c. The
> implementation is based on NCSI spec (version: 1.1.0):
> https://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.1.0.pdf

Series applied, thanks.
