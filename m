From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] tcp: simplify ack tx timestamps
Date: Thu, 28 Apr 2016 16:06:32 -0400 (EDT)
Message-ID: <20160428.160632.1686396634047973672.davem@davemloft.net>
References: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com, willemb@google.com,
	edumazet@google.com, ycheng@google.com, ncardwell@google.com,
	soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbcD1UGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:06:35 -0400
In-Reply-To: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Wed, 27 Apr 2016 23:38:59 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> v2:
> - Fully remove SKBTX_ACK_TSTAMP, as suggested by Willem de Bruijn.
> 
> This patch series aims at removing redundant checks and fields
> for ack timestamps for TCP.

Series applied, thank you.
