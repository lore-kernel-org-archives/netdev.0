From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: Utilize FW 8.10.3.0
Date: Thu, 02 Jun 2016 21:30:23 -0700 (PDT)
Message-ID: <20160602.213023.482529740569317343.davem@davemloft.net>
References: <1464852209-7175-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbcFCEaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 00:30:24 -0400
In-Reply-To: <1464852209-7175-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 2 Jun 2016 10:23:29 +0300

> The New QED firmware contains several fixes, including:
>   - Wrong classification of packets in 4-port devices.
>   - Anti-spoof interoperability with encapsulated packets.
>   - Tx-switching of encapsulated packets.
> It also slightly improves Tx performance of the device.
> 
> In addition, this firmware contains the necessary logic for
> supporting iscsi & rdma, for which we plan on pushing protocol
> drivers in the imminent future.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
