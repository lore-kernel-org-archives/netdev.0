From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: Handle txstamp_ack when
 fragmenting/coalescing skbs
Date: Sun, 24 Apr 2016 14:07:36 -0400 (EDT)
Message-ID: <20160424.140736.103102038829975762.davem@davemloft.net>
References: <1461131448-1460418-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
	soheil@google.com, willemb@google.com, ycheng@google.com,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbcDXSHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 14:07:45 -0400
In-Reply-To: <1461131448-1460418-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 19 Apr 2016 22:50:46 -0700

> This patchset is to handle the txstamp-ack bit when
> fragmenting/coalescing skbs.
 ...

Series applied, thanks.
