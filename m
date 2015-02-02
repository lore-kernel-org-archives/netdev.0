From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rocker: Add support for retrieving port level
 statistics
Date: Sun, 01 Feb 2015 23:17:55 -0800 (PST)
Message-ID: <20150201.231755.373632234443982867.davem@davemloft.net>
References: <1422590373-22807-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbBBHRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 02:17:55 -0500
In-Reply-To: <1422590373-22807-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 29 Jan 2015 20:59:33 -0700

> Add support for retrieving port level statistics from device.
> Hook is added for ethtool's stats functionality. For example,
> 
> $ ethtool -S eth3
> NIC statistics:
>      rx_packets: 12
>      rx_bytes: 2790
>      rx_dropped: 0
>      rx_errors: 0
>      tx_packets: 8
>      tx_bytes: 728
>      tx_dropped: 0
>      tx_errors: 0
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied to net-next, thanks.
