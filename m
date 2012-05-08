From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] netxen_nic: Allow only useful and
 recommended firmware dump capture mask values
Date: Tue, 08 May 2012 12:52:22 -0400 (EDT)
Message-ID: <20120508.125222.240635846737537203.davem@davemloft.net>
References: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
	<1336489288-22347-3-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	sony.chacko@qlogic.com, manish.chopra@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757256Ab2EHQw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 12:52:26 -0400
In-Reply-To: <1336489288-22347-3-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Tue, 8 May 2012 08:01:26 -0700

> +/* Fw dump levels */
> +static const u32 FW_DUMP_LEVELS[] = {
> +	0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff };

Format this more reasonably, this looks terrible.
