From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V5 6/9] Altera TSE: Add main and header file
 for Altera Ethernet Driver
Date: Fri, 14 Mar 2014 15:05:53 -0400 (EDT)
Message-ID: <20140314.150553.344629720807805639.davem@davemloft.net>
References: <1394805887-22030-1-git-send-email-vbridgers2013@gmail.com>
	<1394805887-22030-7-git-send-email-vbridgers2013@gmail.com>
	<20140314143918.GA2253@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridgers2013@gmail.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbaCNTFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 15:05:55 -0400
In-Reply-To: <20140314143918.GA2253@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 14 Mar 2014 15:39:18 +0100

> This could use a call to skb_tx_timestamp() somewhere around here.

This can happen in a follow-up patch, I won't block the initial
submission just for this.
