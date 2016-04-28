From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bpf: fix several bugs
Date: Thu, 28 Apr 2016 17:30:18 -0400 (EDT)
Message-ID: <20160428.173018.367287857434534642.davem@davemloft.net>
References: <1461808582-1452466-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jannh@google.com,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbcD1VaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:30:21 -0400
In-Reply-To: <1461808582-1452466-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 27 Apr 2016 18:56:19 -0700

> First two patches address bugs found by Jann Horn.
> Last patch is a minor samples fix spotted during the testing.

Series applied and queued up for -stable, thanks.
