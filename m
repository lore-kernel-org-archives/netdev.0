From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tipc: link state processing improvements
Date: Mon, 07 Jul 2014 19:56:11 -0700 (PDT)
Message-ID: <20140707.195611.860646964164841639.davem@davemloft.net>
References: <1404202961-30262-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	ying.xue@windriver.com, richard.alpe@ericsson.com,
	tipc-discussion@lists.sourceforge.net,
	carl.sigurjonsson@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbaGHC4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 22:56:12 -0400
In-Reply-To: <1404202961-30262-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Tue, 1 Jul 2014 10:22:39 +0200

> Message delivery is separated from the link state processing, and
> we fix a bug in receive-path triggered acks.

Series applied, thanks.
