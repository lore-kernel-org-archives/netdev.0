From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Driver: Vmxnet3: segCnt can be 1 for LRO packets
Date: Tue, 07 Jun 2016 22:59:10 -0700 (PDT)
Message-ID: <20160607.225910.2110750723685096426.davem@davemloft.net>
References: <1465365317-120893-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, heoj@vmware.com
To: skhare@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216AbcFHF7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 01:59:14 -0400
In-Reply-To: <1465365317-120893-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrikrishna Khare <skhare@vmware.com>
Date: Tue,  7 Jun 2016 22:55:17 -0700

> The device emulation may send segCnt of 1 for LRO packets.
> 
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> Signed-off-by: Jin Heo <heoj@vmware.com>

Please do not capitalize subsystem prefixes in your Subject line,
and "Driver: " is so generic that it's pointless to use it as a
part of the subsystem prefix.  Plain "vmxnet3: " is sufficient.
