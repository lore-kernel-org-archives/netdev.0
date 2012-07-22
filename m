From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Tx time stamp advertising for four drivers
Date: Sun, 22 Jul 2012 12:33:50 -0700 (PDT)
Message-ID: <20120722.123350.1944688207454608943.davem@davemloft.net>
References: <cover.1342976654.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab2GVTdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:33:50 -0400
In-Reply-To: <cover.1342976654.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 22 Jul 2012 19:15:38 +0200

> This series updates the ethtool code for four drivers that recently
> add the skb_tx_timestamp hook. Since these drivers now support
> software transmit time stamps, let us also advertise this via ethtool.

Series applied, thanks.
