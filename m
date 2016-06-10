From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vmxnet3: segCnt can be 1 for LRO packets
Date: Fri, 10 Jun 2016 00:15:21 -0700 (PDT)
Message-ID: <20160610.001521.416745882807129497.davem@davemloft.net>
References: <1465366415-124072-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, heoj@vmware.com
To: skhare@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcFJHPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 03:15:22 -0400
In-Reply-To: <1465366415-124072-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrikrishna Khare <skhare@vmware.com>
Date: Tue,  7 Jun 2016 23:13:35 -0700

> The device emulation may send segCnt of 1 for LRO packets.
> 
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> Signed-off-by: Jin Heo <heoj@vmware.com>

Applied.
