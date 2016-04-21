From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: Handle txstamp_ack when
 fragmenting/coalescing skbs
Date: Thu, 21 Apr 2016 14:52:14 -0400 (EDT)
Message-ID: <20160421.145214.1247460795823743769.davem@davemloft.net>
References: <1461131448-1460418-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
	soheil@google.com, willemb@google.com, ycheng@google.com,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbcDUSwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:52:16 -0400
In-Reply-To: <1461131448-1460418-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 19 Apr 2016 22:50:46 -0700

> The second patch depends on the recently posted series
> for the net branch:
> "tcp: Merge timestamp info when coalescing skbs"

I'll therefore apply this after I do my next merge of net into
net-next, just FYI...
