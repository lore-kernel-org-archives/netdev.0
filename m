From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Thu, 24 Jul 2014 17:53:05 -0700 (PDT)
Message-ID: <20140724.175305.635580164514156857.davem@davemloft.net>
References: <CA+FuTSfm_WXtFYDeUNspN4=VNAAaQRxe2mvUYDD9Ho-yqJt8GA@mail.gmail.com>
	<20140724.165053.659177921712979472.davem@davemloft.net>
	<CA+FuTSdVFHVEp0-orPe7KNEbF2-Lsu+myBNdi9bW7kVV3FM6cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com, kreese@caviumnetworks.com,
	ddaney@caviumnetworks.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934900AbaGYAxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 20:53:10 -0400
In-Reply-To: <CA+FuTSdVFHVEp0-orPe7KNEbF2-Lsu+myBNdi9bW7kVV3FM6cA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 24 Jul 2014 20:10:55 -0400

> They will still receive hardware timestamps in raw format. The
> only feature that is deprecated is hardware timestamps
> converted to system time format (ptp_to_ktime).

OK.
