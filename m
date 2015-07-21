From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Couple of classifier fixes
Date: Tue, 21 Jul 2015 00:25:38 -0700 (PDT)
Message-ID: <20150721.002538.412220244781527914.davem@davemloft.net>
References: <cover.1437163466.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbbGUHZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:25:40 -0400
In-Reply-To: <cover.1437163466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 17 Jul 2015 22:38:42 +0200

> This fixes a couple of panics in the form of (analogous for
> cls_flow{,er}):
 ...
> I've split them into 3 patches, so they can be backported easier
> when needed.

Series applied and queued up for -stable, thanks.
